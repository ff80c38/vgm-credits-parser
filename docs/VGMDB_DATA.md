# VGMdb Data

## Overview

The `vgmdb_data` folder contains some artist role information scraped from VGMdb and partial tag mappings for all roles. The mapping from roles to vorbis tags is implemented via a fuzzy search, checking the available roles and aliases. Please note that not all aliases were scraped from VGMdb due to the fragmentation of the data - only a selected few roles have their aliases included with this data.

**Data last updated:** 2026-01-24

## Files

* `vgmdb_roles.tsv` - Tab-separated file containing artist roles, aliases, and tag mappings
* `vgmdb_roles_scraper.R` - Scraper script for updating the data

## Data Source

All information on artist roles and their aliases are taken directly from [VGMdb](https://vgmdb.net). Please note that the tag mappings are not from VGMdb. Instead they were created by the included script as VGMdb usually does not interpret credits.

## Update 2026-02-09

With VGMdb's new Cloudflare protection this script has become mostly dysfunctional. The following steps describe the workflow as it was before the new measures were taken.

## Updating the Data

To update `vgmdb_roles.tsv` yourself:

1. Run the script `vgmdb_roles_scraper.R`
2. When prompted, enter your VGMdb username and password
3. Wait for the scraping process to complete

## Notes

**Authentication Required**: You will need a VGMdb account to access role information. The script will prompt you for credentials during execution.

**Rate Limiting**: Please do not disable the built-in rate limitation to prevent flooding VGMdb with requests.
