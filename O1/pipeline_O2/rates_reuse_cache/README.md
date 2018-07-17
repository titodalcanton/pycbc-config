# O1 Re-analysis Rates Rerun Cache Files #

This directory contains the cache files needed to perform rates
analyses of the C02 O1 data using the O2 pipeline, while reusing
products from the full-data analysis (performed on CIT).

These files are *only* designed to be used on the CIT cluster, as they
reference files there, and also *only* for a workflow that will run
all inspiral jobs on the Open Science Grid. The appropriate file for a
given analysis should be provided to `pycbc_submit_dax` via the
`--cache-file` option.

*WARNING:* When planning workflows that are intended to use these
 files, be sure that when planning the workflow with
 `pycbc_make_coinc_search_workflow`, you have set the
 `file-retention-level` of the `workflow` section of configuration
 file to be `merged-triggers`. If you have not done this in the
 configuration file itself (usually you would not) then you can do
 this when running `pycbc_make_coinc_search_workflow` by providing the
 following override:
```
--config-overrides [generally many other overrides] "workflow:file-retention-level:merged_triggers" 
```
If you fail to do this, then at the very least, all of the full-data
 inspiral jobs will be rerun, defeating the purpose of this file reuse
 in the first place.
