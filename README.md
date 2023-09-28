# Get PDB Id

This utility is designed to retrieve the GUID (Globally Unique Identifier) from a PDB (Program Database) file. In addition to this, it can generate a ***SymStore***-compatible ID, facilitating the creation of your own ***SymStore*** population tool. 

## Usage

```bash
$ get_pdb_id <pdb-file> [options]
```

### Options

- `-ssid`, `--symstore-id`: Generate a ***SymStore***-compatible ID.

## Example

```bash
$ get_pdb_id myfile.pdb --symstore-id
```

Execute this command to obtain the ***SymStore***-compatible ID for the 'myfile.pdb' file.

## Remarks

The utility will output either the GUID or the ***SymStore***-compatible ID upon successful operation. In case of failure, it will print nothing and return `-1`.

## Building from Source

To build this utility from source, follow these steps:

```bash
$ generate.bat
$ start .build\get_pdb_id.sln
```

> **Note**: If you're not using Windows or you have a different IDE/build system preference, you'll need to adjust the `generate.bat` script accordingly.
