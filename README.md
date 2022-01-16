# trueupdate
A TrueCharts automatic and bulk update utility

## How to install

run `pip install trueupdate`

Please be aware you will need to reinstall after every SCALE update

## How to Update

run `pip install --upgrade trueupdate`

## How to use

Just run `trueupdate` in the shell of your TrueNAS SCALE machine, to have it process Patch and Minor version updates for all Apps

Additional options are available:

- `trueupdate CATALOG` where CATALOG is the name of the catalog you want to process in caps
- `trueupdate Semver` where semver is the highest semver version you want to process. options: `patch`, `minor` and `major`