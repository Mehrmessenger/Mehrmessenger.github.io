-- Mehr Messenger — Supabase schema (run in SQL Editor)
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  username text unique not null check (username ~ '^[a-z0-9_]{3,24}$'),
  display_name text not null,
  bio text, avatar_url text,
  created_at timestamptz default now()
);

create table chats (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('group','channel')),
  handle text unique check (handle ~ '^[a-z0-9_]{3,24}$'),
  name text not null check (char_length(name) between 2 and 40),
  description text check (char_length(description) <= 140),
  avatar_url text,                       -- group/channel photo (max 500 KB, see bucket below)
  is_public boolean default false,
  owner_id uuid not null references profiles(id),
  created_at timestamptz default now()
);

create table members (
  chat_id uuid references chats(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','admin','member')),
  primary key (chat_id, user_id)
);

create table messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references chats(id) on delete cascade,
  sender_id uuid not null references profiles(id),
  body text check (char_length(body) <= 2000),
  media_url text,
  reply_to uuid references messages(id),
  edited boolean default false, deleted boolean default false,
  created_at timestamptz default now()
);
create index on messages (chat_id, created_at desc);

alter table profiles enable row level security;
alter table chats    enable row level security;
alter table members  enable row level security;
alter table messages enable row level security;

create or replace function is_member(c uuid) returns boolean
language sql security definer set search_path = public as
$$ select exists(select 1 from members where chat_id = c and user_id = auth.uid()) $$;

create or replace function is_admin(c uuid) returns boolean
language sql security definer set search_path = public as
$$ select exists(select 1 from members where chat_id = c and user_id = auth.uid() and role in ('owner','admin')) $$;

create policy "profiles readable" on profiles for select using (true);
create policy "own profile write" on profiles for all using (id = auth.uid()) with check (id = auth.uid());

create policy "chats readable" on chats for select using (is_public or is_member(id) or owner_id = auth.uid());
create policy "create chat"    on chats for insert with check (owner_id = auth.uid());
create policy "admins edit chat (name, photo...)" on chats for update using (is_admin(id));
create policy "owner delete chat" on chats for delete using (owner_id = auth.uid());

create policy "see members" on members for select using (is_member(chat_id));
create policy "join self / admins add" on members for insert
  with check (user_id = auth.uid() or is_admin(chat_id));
create policy "leave / admins remove" on members for delete
  using (user_id = auth.uid() or is_admin(chat_id));

create policy "read messages" on messages for select using (is_member(chat_id));
create policy "send messages" on messages for insert with check (
  sender_id = auth.uid() and is_member(chat_id)
  and (not exists(select 1 from chats where id = chat_id and kind = 'channel') or is_admin(chat_id))
);
create policy "edit own message" on messages for update using (sender_id = auth.uid());

-- Avatar bucket: public read, 500 KB limit, images only
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 524288, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

create policy "avatars public read" on storage.objects for select using (bucket_id = 'avatars');
create policy "avatars upload (own folder)" on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

alter publication supabase_realtime add table messages;
