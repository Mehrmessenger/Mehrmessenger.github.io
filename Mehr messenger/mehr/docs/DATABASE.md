# اتصال به پایگاه داده‌ی رایگان (Supabase)

> وضعیت فعلی: برنامه همه‌چیز را در `localStorage` نگه می‌دارد؛ پس چت فقط بین حساب‌های **همان مرورگر** کار می‌کند.
> برای چت واقعی بین دستگاه‌ها باید لایه‌ی ذخیره‌سازی به سرور وصل شود. ساده‌ترین مسیر رایگان: **Supabase**
> (Postgres + احراز هویت + Realtime + ذخیره‌ی فایل). محدودیت‌های پلن رایگان ممکن است عوض شود؛ در supabase.com/pricing چک کنید.

## گام‌ها
1. در supabase.com با حساب GitHub ثبت‌نام و یک Project بسازید (Region نزدیک؛ رمز دیتابیس را نگه دارید).
2. SQL Editor ← محتوای `docs/schema.sql` را اجرا کنید (جدول‌ها + قوانین امنیتی RLS + باکت عکس‌ها با سقف ۵۰۰ کیلوبایت).
3. Project Settings ← API: مقدارهای `Project URL` و `anon public key` را بردارید. (کلید `service_role` را **هرگز** در فرانت‌اند نگذارید.)
4. در `index.html` قبل از اسکریپت‌های برنامه اضافه کنید:
   ```html
   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.min.js"></script>
   <script>const sb = supabase.createClient('PROJECT_URL', 'ANON_KEY');</script>
   ```
5. توابع ذخیره‌سازی را جایگزین کنید (جایگزینی تدریجی، به این ترتیب):
   - ثبت‌نام/ورود ← `sb.auth.signUp / signInWithPassword` (به‌جای رمزهای ذخیره‌شده در مرورگر)
   - ساخت گروه/کانال ← `sb.from('chats').insert(...)`
   - ارسال پیام ← `sb.from('messages').insert(...)`
   - دریافت لحظه‌ای ← `sb.channel('room').on('postgres_changes', {event:'INSERT', schema:'public', table:'messages'}, cb).subscribe()`
   - عکس گروه/کانال ← `sb.storage.from('avatars').upload(path, file)` و ذخیره‌ی لینک در `chats.avatar_url`
6. در Authentication ← URL Configuration، آدرس GitHub Pages خود را اضافه کنید.

## نکات امنیتی
- کلید `anon` عمومی است؛ امنیت واقعی با **RLS** (در `schema.sql`) تأمین می‌شود.
- مجوزها (مالک/ادمین) باید در RLS چک شوند، نه فقط در جاوااسکریپت.
- در پلن رایگان، پروژه‌ی بدون فعالیت ممکن است متوقف شود؛ از داشبورد دوباره فعالش کنید.

## جایگزین‌ها
Firebase (Firestore + Auth)، یا Cloudflare Workers + D1 — اگر خواستید راهنمایش را هم می‌نویسم.
