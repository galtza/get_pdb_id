# Get PDB Id

A simple utility designed to retrieve the GUID (Globally Unique Identifier) from a PDB (Program Database) file. It can optionally return a SymStore-compatible ID to allow users to populate a SymStore with their own system.

## Usage

```bash
$ get_pdb_id <pdb-file> [options]
```

### Options

- `-ssid`, `--symstore-id`: Generate a SymStore-compatible ID.

## Example

```bash
$ get_pdb_id myfile.pdb --symstore-id
```

This command will return the SymStore-compatible ID of the PDB file named 'myfile.pdb'.

## Remarks

On success, the program prints the GUID or SymStore-compatible ID of the PDB file. In case of failure, the program prints nothing and returns -1.

## Building

Instructions for building the utility from source can be placed here...

```bash
$ generate.bat
$ start .build\get_pdb_id.sln
```

> Note: If you're not using Windows or you prefer to use a different Integrated Development Environment (IDE) or build system, you will need to modify the generate.bat script to accommodate your preferences.
