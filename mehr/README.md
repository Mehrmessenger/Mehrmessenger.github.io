# Mehr Messenger | مهر مسنجر

پیام‌رسان تک‌فایل (HTML/CSS/JS) با رابط فارسی/انگلیسی، چت شخصی، گروه و کانال.
A single-file messenger web app (Persian/English) with chats, groups and channels.

## امکانات / Features
- چت شخصی، گروه و کانال (عمومی و خصوصی) / Personal chats, groups, channels
- **عکس پروفایل برای گروه و کانال** (حداکثر ۵۰۰ کیلوبایت؛ خودکار به ۲۵۶×۲۵۶ بهینه می‌شود)
  Group & channel profile photos (max 500 KB, auto-cropped to 256×256)
- پیام صوتی، ارسال عکس، پاسخ، ویرایش، سنجاق، واکنش / Voice, photos, reply, edit, pin, reactions
- تم تاریک/روشن، فارسی/انگلیسی / Dark & light theme, FA/EN

## اجرا / Run locally
فایل `index.html` را در مرورگر باز کنید. نیازی به نصب چیزی نیست.
Just open `index.html` in a browser. No build step.

## انتشار رایگان روی GitHub Pages
1. ریپو را بسازید و فایل‌ها را روی شاخه‌ی `main` آپلود کنید.
2. Settings ← Pages ← Source: **GitHub Actions**
3. با هر push، سایت خودکار منتشر می‌شود (`.github/workflows/pages.yml`).

## وضعیت داده‌ها / Data
هم‌اکنون همه‌چیز در `localStorage` مرورگر ذخیره می‌شود (حدود ۵ مگابایت).
برای چت واقعی بین دستگاه‌ها، راهنمای [docs/DATABASE.md](docs/DATABASE.md) را ببینید.

## مجوز / License
MIT
