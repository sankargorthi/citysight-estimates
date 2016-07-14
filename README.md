# CitySight Estimates
These scripts are used to generate Citation Estimates for cities

They are driven off of the `writeconfig.yml` file located at the root folder.

## Workflow
- These scripts run once daily
- The scripts consume data from `ISSUANCE`, `CORRECTEDBEATS`, etc.
- Estimates for the targeted cities will be written to CSV files.
- These CSV records are then inserted into the expectations tables.

## Setup

```bash
$ cp writeconfig.dist.yml writeconfig.yml
```
Specify the city's DB credentials following the examples given.

## Usage

```bash
PS> estimates.sh
```

# License
(c) PARC 2016. All Rights Reserved.
