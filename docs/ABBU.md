<!-- docs/ABBU.md -->

# ABBU File Format (Apple Contacts Archive)

## Overview

`.abbu` files are exported from Apple Contacts.app and represent a full address book archive.

They are **not** a single file format — they are a macOS "package" (a directory bundle that Finder
presents as a single file). This means you can inspect the contents with `ls` or `open -a Finder`.

## Structure

Typical contents of a `.abbu` bundle:

```text
Contacts.abbu/
├── AddressBook-v22.abcddb   ← SQLite database for "Local" contacts (often mostly empty)
├── Metadata/                ← plist files (bundle metadata)
│   └── *.abcdp
├── Images/                  ← contact photos (JPEG/PNG)
│   └── <uuid>.jpg
├── Sources/                 ← Remote synced accounts (iCloud, Exchange, Google)
│   ├── <account_uuid>/
│   │   ├── AddressBook-v22.abcddb  ← SQLite database for this specific account
│   │   ├── Metadata/
│   │   └── Images/
│   └── <another_uuid>/...
└── Records/                 ← legacy plist-based contact records (older macOS)
    └── <uuid>.abcdp
```

> **Note:** The most common pitfall when parsing `.abbu` files is only reading the root `AddressBook-v22.abcddb`. For users syncing via iCloud or Exchange, the root database will be nearly empty. Parsers must recursively scan the `Sources/` directory to discover and extract all contacts from all `.abcddb` files.

## Formats

### 1. SQLite (modern macOS)

Newer macOS versions store the address book in a single SQLite database:

```
AddressBook-v22.abcddb
```

Key tables:

| Table                    | Purpose                                |
|--------------------------|----------------------------------------|
| `ZABCDRECORD`            | One row per contact (name, company)    |
| `ZABCDEMAILADDRESS`      | Email addresses (linked by `ZOWNER`)   |
| `ZABCDPHONENUMBER`       | Phone numbers (linked by `ZOWNER`)     |
| `ZABCDPOSTALADDRESS`     | Street addresses (linked by `ZOWNER`)  |
| `Z_ABCDCONTACTGROUP`     | Group membership join table            |
| `ZABCDURLADDRESS`        | URLs (linked by `ZOWNER`)              |
| `ZABCDNOTE`              | Notes (linked by `ZCONTACT`)           |
| `ZABCDRELATEDNAME`       | Related names (linked by `ZOWNER`)     |
| `ZABCDSOCIALPROFILE`     | Social profiles (linked by `ZOWNER`)   |

Notable columns in `ZABCDRECORD`:

| Column                   | Description              |
|--------------------------|--------------------------|
| `Z_PK`                   | Primary key              |
| `Z_ENT`                  | Entity type (14=contact) |
| `ZFIRSTNAME`             | First name               |
| `ZLASTNAME`              | Last name                |
| `ZNICKNAME`              | Nickname                 |
| `ZTITLE`                 | Prefix (e.g. "Dr.")      |
| `ZSUFFIX`                | Suffix (e.g. "Jr.")      |
| `ZORGANIZATION`          | Company / org            |
| `ZJOBTITLE`              | Job title                |
| `ZDEPARTMENT`            | Department               |
| `ZMAIDENNAME`            | Maiden name              |
| `ZPHONETICFIRSTNAME`     | Phonetic first name      |
| `ZPHONETICLASTNAME`      | Phonetic last name       |
| `ZPHONETICORGANIZATION`  | Phonetic company         |
| `ZPRONOUNS`              | Pronouns                 |
| `ZRINGTONE`              | Ringtone                 |
| `ZTEXTTONE`              | Text tone                |

### 2. Plist / `.abcdp` (legacy macOS)

Older macOS versions stored each contact as a separate binary plist file under `Records/`.
Each file is a serialised `ABPerson` dictionary. The `abbu` gem currently stubs this parser
and returns an empty array with a warning.

## Export Steps

To create a `.abbu` file:

1. Open **Contacts.app** on macOS
2. Select all contacts (`⌘A`)
3. File → Export → **Export vCard** *(or)* File → Export → **Contacts Archive…**

The "Contacts Archive" option produces a `.abbu` bundle.

## References

- [Apple Contacts Framework (private)](https://developer.apple.com/documentation/contacts)
- [SQLite3 gem](https://github.com/sparklemotion/sqlite3-ruby)
- macOS `AddressBook.framework` private headers (reverse-engineered)

---
Stan Carver II
Made in Texas 🤠
https://stancarver.com
