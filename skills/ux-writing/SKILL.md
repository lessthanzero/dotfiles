---
name: ux-writing
description: Practical UX writing and UI microcopy guidelines distilled from "Пиши, сокращай" (инфостиль) and Plain English standards. Use when writing, reviewing, or editing UI text, button labels, CTAs, error states, empty states, form hints, modal dialogues, or product documentation in Russian or English.
---

# UX Writing & Interface Microcopy (Инфостиль)

High-signal heuristics for crafting precise, honest, and actionable interface copy across Russian and English, distilled from Maxim Ilyahov & Lyudmila Sarycheva's *«Пиши, сокращай»* (2025) and modern Plain English interface standards.

---

## 1. Core Principles: Strong Interface Text

1. **Benefit & Facts First**: State concrete capabilities, numbers, and outcomes. Never use ungrounded emotional adjectives (*revolutionary, seamless, powerful, blazing-fast*).
   - ❌ *Our intuitive AI effortlessly organizes your notes.*
   - ✅ *Tags, links, and indexes your notes in under 2 seconds.*
2. **Action Over Process**: Replace nominalizations (отглагольные существительные) and passive constructions with active, imperative verbs.
   - ❌ *Осуществление экспорта данных* / *Performing data export*
   - ✅ *Экспортировать данные* / *Export data*
3. **No False Politeness or Guilt**: Avoid patronizing apologies (*Oops! Something went wrong!*) and dark-pattern confirm-shaming (*No thanks, I hate saving money*). Be calm, direct, and respectful.
4. **Contextual Brevity**: Short is good, but clarity beats brevity. Never cut words if removing them introduces ambiguity in destructive or transactional flows.

---

## 2. Component Patterns & Formulas

### A. Buttons & CTAs: `[Active Verb] + [Specific Object]`
- Always tell the user exactly what will happen when clicked.
- ❌ `Отправить`, `Продолжить`, `Submit`, `Click Here`, `OK`
- ✅ `Создать проект`, `Экспортировать в CSV`, `Сохранить черновик`, `Connect Wallet`, `Create Workspace`
- **Destructive Actions**: Name the exact consequence.
  - ❌ `Удалить`, `Delete`
  - ✅ `Удалить репозиторий`, `Delete 3 recordings permanently`

### B. Error States: The 3-Part Recovery Formula
Every actionable error must provide three pieces of information without technical obscurities:
```
1. [What happened]      — Clear, plain-language description of the obstacle.
2. [Why it happened]    — Context (network timeout, invalid input, permission).
3. [How to fix it]      — Explicit single next action or direct fallback.
```
- ❌ *Error 504: Gateway Timeout.*
- ❌ *Ой, произошла непредвиденная ошибка! Попробуйте позже.*
- ✅ **Сервер не отвечает.** Проверьте подключение к Wi-Fi и нажмите «Повторить».
- ✅ **Card declined by bank.** Please check your billing address or try a different card.

### C. Empty States: Orientation & Activation
An empty state must never just be "No items found".
```
1. [Headline]    — Name the missing artifact clearly (e.g. «Пока нет сохранённых отчётов»).
2. [Body]        — Explain how items arrive here or why it is empty.
3. [Primary CTA] — Single button to create or fetch the first item.
```

### D. Modal Dialogs & Confirmations
- **Title**: Ask the exact question or state the exact action (`Удалить ветку feature/auth?`).
- **Body**: State whether the action is reversible and what data is affected.
- **Buttons**: Two buttons with mirrored verbs.
  - Primary (Destructive): `Удалить ветку` (danger styling)
  - Secondary (Safe): `Отмена`

---

## 3. Language-Specific Traps

### Русский язык (Инфостиль):
- **Канцелярит и отглагольные**: Заменяй на глаголы (*произвести настройку* → *настроить*; *в целях обеспечения безопасности* → *для безопасности*).
- **Пассивный залог**: Переводи в активный субъект-действие (*файл был успешно загружен системой* → *файл загружен* или *система загрузила файл*).
- **Штампы и плеоназмы**: Вырезай словесный мусор (*в настоящий момент времени* → *сейчас*; *полная ликвидация* → *удаление*).
- **Местоимения**: Минимизируй «свой», «ваш», «свои» там, где принадлежность очевидна (*введите ваш пароль* → *введите пароль*).

### English (Plain Language):
- **Corporate Buzzwords**: Strike out *leverage, empower, synergy, holistically, robust, scalable*.
- **Preposition Stacking**: Simplify (*with the exception of* → *except*; *in order to* → *to*).
- **Title vs Sentence Case**: Default to Sentence case for buttons, modals, and headings (*Create account*, not *Create Account*), maintaining calm, modern typography.

---

## 4. Trigger Boundaries

- **Activate for**: Interface strings, button labels, validation messages, modal prompts, empty states, onboarding tooltips, status badges, and CLI command documentation.
- **Do NOT activate for**: Code comments, commit messages (unless specifically requested), backend algorithms, legal contract phrasing, or marketing longform stories.
