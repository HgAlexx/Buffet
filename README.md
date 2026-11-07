**Buffet** is a food/water macro generator originally developed by **[tekkub](http://www.tekkub.net/)** and currently maintained by **mZHg**.

---

What's new :
- Added support for Wow Forever: please report any detection issue!

---

Feel free to report any bug or request any feature [here](https://github.com/HgAlexx/Buffet/issues) :)

---

Features:

- Dynamically scan your bag for usable food, drink, potion, rune, managem and bandage
- Provide 6 macros auto-magically updated (out of combat)
  - Consumable and food/drink
  - Food and Drink only
  - Consumable only
- Allow configuration of modifiers used by macros
- Option to default macros to hearthstone if no item found
- Option to consider "well-fed" food items in macros
- Option to consider "toxic" potion items in macros
- Support dark and demonic runes
- Support Classic Wow
- Custom macro using lua scripting language, see [here](https://github.com/HgAlexx/Buffet/wiki) for more info
- User-defined ignore list (per characters)

---

Interface localization:

- English is the fallback for untranslated interface strings.
- Simplified Chinese (zhCN) is selected automatically from the game client locale.
- Settings, custom macro controls and sample comments, confirmations, launcher tooltips, About, chat messages and slash-command help use the shared UI string table in UILocalization.lua.
- UI strings are separate from item-tooltip matching patterns. Macro identifiers, commands and existing user settings retain their values.
- To add another interface language, populate the UI table for that locale; missing entries fall back to their English keys. Preserve formatting placeholders and macro syntax in translations.

Simplified Chinese item detection:

- All seven game variants select the shared vocabulary and patterns in ItemLocalization.zhCN.lua.
- Recognition handles Chinese food/drink and conjured-item markers, fixed amounts, ranges using either 至 or 到, comma-separated thousands, and percentages before or after the resource name.
- Combined health/mana effects support shared or separate values in either order. Per-second restoration uses its duration; an amount already expressed as a total is not multiplied again.
- Ordinary recovery text does not mark an item as well-fed food. Bandages accept the recovery wording used by Chinese tooltips.
- Item caches are rebuilt when the client/addon version, language or parser revision changes. Existing macros, custom macro source and ignore lists are retained.
- For an in-game check, use /buffet debug followed by an item link to inspect a fresh parse, and /buffet info followed by the link to inspect its cached result.

Currently supporting the following item-detection localizations:

For Retail:
- English (enUS)
- Deutsch (deDE)
- Español (esES)
- Français (frFR)
- Italiano (itIT)
- Brazilian Portuguese (ptBR) provided by Lucas Fell
- Русский (ruRU) provided by ZamestoTV

For Mists:
- English (enUS)
- Deutsch (deDE)
- Español (esES)
- Français (frFR)
- Brazilian Portuguese (ptBR) provided by Lucas Fell
- Korean (koKR) provided by coderhyme

For TBC:
- English (enUS)
- Deutsch (deDE)
- Español (esES)
- Français (frFR)
- Brazilian Portuguese (ptBR) provided by Lucas Fell

For Classic:
- English (enUS)
- Deutsch (deDE)
- Español (esES)
- Brazilian Portuguese (ptBR) provided by Lucas Fell
- Français (frFR)


Partially supporting the following localizations:

For Retail, Mists, TBC and Classic:
- Simplified Chinese (zhCN) provided by Witnesscm, with additional fixes for WtLK by clijiac

---

If you want to contribute to localizations, [pull requests](https://github.com/HgAlexx/Buffet/pulls) are welcome!
