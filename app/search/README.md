# search

## Installation
app-install https://github.com/walterjwhite/search

## Intent
'Search' is intended to aid in locating content within a git project.
It relies on git grep to search contents and find for searching filenames and paths.

## Usage
This 'app' is designed to be run in a git working directory.


### Contents (default)
> search **'search-string'**

  will search contents for **'search-string'**.

### Filenames
> search --filenames **'search-string'**

  will search filenames for **'search-string'**', if you want to match a pattern in a filename or path, you can use **'\*search-string\*'**.

### Changes
> search --changes **'search-string'**

  will search changes for **'search-string'**.

### Logs
> search --logs **'search-string'**

  will search log messages for **'search-string'**.

### Scopes
Search will only search the git working directory of the current project.
If search is run outside of a git working directory, and it detects git working directories in subdirectories, then a recursive search will be performed.
Otherwise an 'all' search will be performed in which the '_CONF_SEARCH_PATH' is searched recursively.


---
### Limitations and known issues
1. Handling of spaces is inconsistent between the search types.
2. Search of flags (--changes) is inconsistent.
3. Search does not run outside of these use cases.

---
### Future work
1. Address handling of spaces.
2. Address handling of flags.
3. Generalize search such that it need not depend on git to search contents.
4. Filter search by filename while looking for specific contents within files, ie. search all Java files for @Controller.
5. Allow output to be easily consumed by downstream apps such as sed / awk / grep.
