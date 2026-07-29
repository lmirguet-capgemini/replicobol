       *> Calendar view combines projects, generated Monday-Friday weeks, and
       *> latest visible weekly-entry values into JSON rows for the frontend.
       01 CALENDAR-VIEW-PATHS.
          05 CALENDAR-PROJECT-PATH PIC X(64) VALUE "data/projects.dat".
          05 CALENDAR-ENTRY-PATH   PIC X(64) VALUE "data/weekly-entries.dat".