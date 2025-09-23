# AutoHotkey Script Search Tool & Indexer

![Preview](https://github.com/elModo7/Script-Search-Tool/blob/main/res/img/sample2.gif?raw=true)

I have **so many scripts** that ***it's become harder and harder to find what I want*** over the years.
This tool aims at addressing just that, you can search by file name or folder (that's how I have been using it so far), and now [this repo gave me the idea of having a preview and content search.](https://github.com/Ixiko/AHK-CodeSearch)

It creates an SQLite database of a specific folder (recursive) and indexes the file contents so that future searchs are pretty much instant.

There are two variants, one with the GUI purely made in AutoHotkey (*below*) and another one with a more visually appealing UI but no file preview (*above*).

![Preview](https://github.com/elModo7/Script-Search-Tool/blob/main/res/img/sample1.gif?raw=true)

## Installation

1. Extract the ZIP archive to a folder of your choice.

---

## Configuration (Before First Run)

Edit the `config.ini` file to fit your setup.

### `indexPath`

- Path to the folder you want to index. Subfolders are also indexed.  
- **Do not use quotation marks**.  
- **Always keep a trailing backslash (`\`)** when indexing a folder.  

Examples:

```
indexPath="C:\ahk\Script Search-Tool 1.0\"   ❌ NOT WORKING
indexPath=C:\ahk\Script Search-Tool 1.0\     ✅ WORKING
indexPath=C:\ahk\Script Search-Tool 1.0      ❌ NOT WORKING
indexPath=C:\ahk\Script Search-Tool 1.0\AHKIndex.ahk  ✅ WORKING (for this file only)
```

### `fileExtensions`

- Comma-separated list of file extensions to include.  
- Wildcards (`*`) are **not supported**.

Examples:

```
fileExtensions=ahk,exe,7z,zip,rar,pdf,txt,html,mhtml,dll
fileExtensions=*   ❌ NOT WORKING
```

### `defaultEditor`

- Path to your preferred editor (no quotation marks).

### `contentIndexed`

- Controls whether **content search** is available.
  - `1` → Shows the "Content Search" checkbox (searches inside file contents when checked).
  - `0` → Hides the "Content Search" checkbox.

---

## First Run

Run the script with the `-recreate` parameter to generate the `.db` file for your configured `indexPath`.

Example:

```
AHKIndex.ahk -recreate
```

---

## Usage

While the script is running:

- **Right-click** the AHK tray icon to open the menu:
  - **Reindex** → Rebuild the index.
  - **Clear config** → Reset configuration.

---

## Notes

- Ensure your `config.ini` is properly set before running.
- Indexing large directories may take some time.

> [!NOTE] 
> I have included my script index so as for you to have a small demo, but you will have to clear the config if you want to use the script on your own file system.
> You can do that through the tray menu once opened.

![Preview](https://github.com/elModo7/Script-Search-Tool/blob/main/res/img/about.png?raw=true)

> [!WARNING] 
> This code is really really old, it is in Spanglish and full of copy-pastes from when I was starting to learn AutoHotkey, use it for the functionality alone, but the code base is terrific for learning or extending from it.
> If you improve it, feel free do make a pull request!
