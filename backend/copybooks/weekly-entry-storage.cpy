       *> Weekly entry records are stored as:
       *> project_code|week_start|days|updated_at
       *> Corrections are stored as:
       *> project_code|week_start|prior_days|replacement_days|replaced_at
       01 WEEKLY-ENTRY-STORAGE-PATH PIC X(64) VALUE "data/weekly-entries.dat".
       01 CORRECTION-STORAGE-PATH PIC X(64) VALUE "data/weekly-entry-corrections.dat".