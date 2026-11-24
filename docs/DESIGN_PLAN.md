# Professional Design Plan — SMS Panel Software (Detailed Screen-by-Screen)

Shakir Nephew ki requirements + Umar ki design shartein

**Platform:** Desktop app NAHI — ye software browser mein chalega aur mobile par bhi. Design Responsive hoga: ek hi design, dono par theek chalega.

**Total Screens:** 12 (+ Splash screen with animation — voice note ki requirement)

Har screen ki mukammal detail neeche hai taake ek ek screen alag design ho sake.
Is ke ilawa 3 shared cheezein har screen par hongi (ye alag screens nahi hain): Sidebar/Topbar layout, Confirm Dialogs, Toast Messages.

---

## Voice note ki extra requirements (Umar)

- Mukammal frontend professionally tayyar karna hai (browser + mobile).
- **Splash screen** add karni hai — proper animation ke saath.
- Har screen ki apni professional animation honi chahiye.
- **Mobile view aur desktop view ki animations alag alag** honi chahiye.
- Background images / graphics professional hon (khud generate ki gayi illustrations).

---

## Responsive Rules (har screen par lagu)

- **Desktop browser (1024px aur upar):** Left sidebar (icons + labels), content right side, tables full width.
- **Tablet (768–1023px):** Sidebar sirf icons wali (collapsed), tables full width.
- **Mobile (768px se neeche):** Sidebar khatam — upar top bar + neeche Bottom Navigation (Dashboard, Database, Send SMS, Reports, More). Tables cards mein badal jayengi (har number ek card). Buttons full-width, tap target kam az kam 48px, text 16px se chhota nahi.
- Har screen pehle mobile par design karke test karna hai, phir desktop — taake dono par easy rahe.

## Screen 1 — Login

- **Maqsad:** Sirf authorized user panel khole.
- **Elements:** Center mein card: Logo + Software ka naam, Username field, Password field (show/hide eye icon), bara Login button, "Forgot password?" link.
- **States:** Galat password par red error message card ke andar; loading spinner button par.
- **Mobile:** Card full-width, fields bare, Login button full-width neeche.

## Screen 2 — Dashboard (Home)

- **Maqsad:** Ek nazar mein poora haal — graphical.
- **Elements:** Upar 4 stat cards (icons ke saath): Total Numbers, Aaj Bhejay Gaye SMS, Total Sent, Failed. Neeche ek line/bar chart (pichle 7 din ke SMS). Us ke neeche Recent Activity list (last 5 actions: number add hua, campaign gaya, waghaira). Ek bara quick-action button: "Naya SMS Bhejo" → seedha Screen 8.
- **States:** Agar data khaali ho to cards par 0 aur chart ki jagah "Abhi koi SMS nahi gaya" wala friendly empty state.
- **Mobile:** Cards 2x2 grid, chart full-width neeche scroll par, bottom nav se har cheez ek tap par.

## Screen 3 — Insert Data / Add Number

- **Maqsad:** Ek number database mein daalna (Shakir ki main baat: data insert).
- **Elements:** Form: Name (text), Mobile Number (03XX-XXXXXXX format, auto-format), Group (dropdown — Screen 7 ke groups), Note (optional). Buttons: Save (primary), Save & Add Another, Cancel.
- **Validations:** Number 11 digits Pakistani format; duplicate number par foran warning "Ye number pehle se database mein hai"; save par green toast "Number save ho gaya".
- **Mobile:** Form ek column, fields full-width, Save button neeche sticky taake scroll na karna pade.

## Screen 4 — Bulk Import

- **Maqsad:** Ek saath bohat saare numbers daalna — waqt bachana.
- **Elements:** Do tareeqay, tabs mein: (A) List Paste — bara text box, ek line mein ek number; (B) File Upload — Excel/CSV file select/drag area. Group select (ye saare numbers kis group mein jayen). Preview table: kitne numbers mile, kitne duplicate nikle (red), kitne galat format (yellow). Button: Import Karo (X numbers).
- **States:** Import ke baad summary: "150 mein se 142 add hue, 5 duplicate, 3 galat".
- **Mobile:** Tabs upar, paste box full-width, preview cards ki surat mein.

## Screen 5 — Database / Numbers List (sab se zyada use hone wali screen)

- **Maqsad:** Saare numbers dekhna, query/search karna, manage karna (Shakir: insert/delete/query yahin se).
- **Elements:** Upar Search bar (name ya number se query), Group filter dropdown, "+ Add Number" button (→ Screen 3), "Import" button (→ Screen 4). Table: Checkbox | Name | Mobile Number | Group | Add hone ki date | Actions (Edit ✎ / Delete 🗑). Neeche pagination ya "Load more". Upar selected count: "12 selected — Delete / SMS bhejo".
- **Actions:** Delete se pehle confirm dialog ("Pakka delete karna hai? Ye wapas nahi aayega"). Edit → Screen 6.
- **States:** Search mein kuch na mile to empty state "Is query par koi number nahi mila".
- **Mobile:** Table ki jagah cards — har card: naam, number, group badge, Edit/Delete icons; search bar upar sticky.

## Screen 6 — Edit Number (Detail)

- **Maqsad:** Ek number ki maloomat badalna.
- **Elements:** Screen 3 jaisa form, pehle se bhara hua (Name, Number, Group, Note). Extra info neeche: kab add hua, is number ko kitne SMS gaye (history chhoti list). Buttons: Save Changes, Delete Number (red, neeche alag), Back.
- **Mobile:** Ek column form, Save neeche sticky.

## Screen 7 — Groups

- **Maqsad:** Numbers ko groups mein rakhna taake group ko SMS bhejna aasan ho (masalan: "Customers", "Students").
- **Elements:** Groups ki list — har group card/row: Group ka naam, us mein kitne numbers hain, Actions (Rename / Delete). Upar "+ New Group" button (chhota dialog: naam likho, Create). Group par click → Screen 5 usi group par filter ho kar khule.
- **States:** Khali group par "0 numbers"; delete par confirm, aur warning agar group mein numbers hain.
- **Mobile:** Cards ek column mein, New Group button full-width upar.

## Screen 8 — Compose & Send SMS (panel ka dil)

- **Maqsad:** Message likhna aur ek click par SMS bhejna (Shakir: SMS jaldi aur click par jaye).
- **Elements:** Recipients select: teen options — All Numbers / Group (dropdown) / Selected (Screen 5 se chune hue) — saath count "128 numbers ko jayega". Message box: bara text area, neeche live counter (English: 160 characters = 1 SMS; Urdu: 70 = 1 SMS; total segments aur andazan kharcha/package count). Preview chhota phone-frame mein ke message kaisa lagega. Sab se bara button: "Send SMS" (green, full prominent). Send se pehle chhota confirm summary: "128 numbers, 2 SMS segments each — Send karun?"
- **States:** Message khaali ho ya recipients 0 hon to Send button disabled (grey) wajah ke saath.
- **Mobile:** Sab ek column; Send button neeche sticky taake hamesha nazar aaye.

## Screen 9 — Sending Queue / Live Progress

- **Maqsad:** Bhejte hue live dekhna ke kya ho raha hai.
- **Elements:** Bara progress bar + percentage (masalan 64/128). Teen counters: Sent ✓ (green), Pending (grey), Failed ✗ (red). Neeche live list: number + status, jo gaya woh tick ho jata hai. Buttons: Pause, Stop (confirm ke saath). Waqfa (delay) ki setting yahin chhoti si: "Har SMS ke baad __ seconds" (planned: 20–30 sec, SIM block se bachne ke liye).
- **States:** Mukammal hone par bada summary card: "128 mein 124 gaye, 4 failed — Report dekho" (→ Screen 10). Failed par "Failed dobara bhejo" button.
- **Mobile:** Progress upar sticky, list neeche scroll, Pause/Stop neeche bare buttons.

## Screen 10 — Reports / History

- **Maqsad:** Purani sending ki tafseel aur report Shakir ko send karna (Shakir ki aakhri baat).
- **Elements:** Upar filters: Date range, Status (All/Sent/Failed), Campaign select. Table/List: Date & time | Number | Message (chhota) | Status badge (Sent green / Failed red) | Failed ki wajah. Upar summary chips: Total / Sent / Failed. Export button (Excel/CSV download) — yehi file Shakir ko bhejni hai. Ek campaign par click → usi campaign ki alag detail isi screen par filter ho kar.
- **Mobile:** List cards mein, filters upar ek "Filter" button ke peeche (sheet), Export button prominent.

## Screen 11 — Settings

- **Maqsad:** Panel ki bunyadi settings ek jagah.
- **Elements:** Sections: (A) Package/Limit: Roz ki SMS limit (100), package mein baqi SMS count (manual update). (B) Sending: Har SMS ke baad default waqfa (seconds), test mode ON/OFF switch. (C) Account: Password change (old + new). Har section ka apna Save button aur save par toast.
- **Mobile:** Sections ek ke neeche ek (accordion), Save har section ke neeche.

## Screen 12 — Gateway / Device

- **Maqsad:** Jis Android phone/SIM se asal SMS jata hai, us ki halat dekhna.
- **Elements:** Bara status card: Gateway Connected (green) / Not Connected (red), phone ka naam/model, SIM number, signal/battery agar mile. Pairing hissa: QR code ya code jo Android gateway app mein daalna hai. Test button: "Test SMS bhejo" (apne number par 1 test). Neeche note: "Phone on, charged aur internet par rakho — warna queue ruk jayegi."
- **States:** Disconnected par wazeh wajah aur "Dobara connect karo" guide ke steps.
- **Mobile:** Status card sab se upar bada, baqi neeche.

---

## Design System (har screen par ek jaisa)

- **Colors:** Primary deep blue (#1D4ED8), background light grey (#F3F4F6) + white cards, Success green, Danger red, Warning amber.
- **Font:** Inter ya Poppins; headings bold; body kam az kam 16px.
- Har screen par ek hi Primary Action sab se numayan — user ko dhoondna na pade.
- Icons har menu item aur button ke saath (graphical requirement).
- **Feedback:** Har action par toast; har destructive action (Delete/Stop) se pehle confirm dialog; khaali screens par friendly empty state, khaali safha kabhi nahi.

## Kaam ka Order

- **Phase 1 — Design:** Ye 12 screens, pehle mobile phir desktop layout.
- **Phase 2 — Frontend:** Design ko browser + mobile responsive code mein.
- **Phase 3 — Backend:** Database (contacts, groups, messages, campaigns, delivery_logs), Insert/Delete/Query, SMS queue + Android gateway, reports/export.

## Shakir se Confirm Karne Wali Baatein (Open Points)

- [ ] Login ek user ka hoga ya zyada users?
- [ ] Numbers zyada tar manual aayenge ya Excel file se?
- [ ] Report Excel mein chahiye ya PDF mein?

_(Voice note ki full saaf transcription abhi chal rahi hai — naya point nikla to ye list aur plan update ho jayega.)_
