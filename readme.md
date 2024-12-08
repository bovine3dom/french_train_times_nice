# what is the new french train timetable for nice like

annoyingly the timetable is a PDF but in fairness probably no-one releases their timetables as CSVs

could maybe get one of the google transport streams but not sure i really trust them.

besides, this way we get to spot all the typos in their PDFs


# extracting tables from pdfs

chatgpt is useless

```
pdftotext -layout FH_04_Grasse_Cannes_Nice_Vintimille_du\ 27\ septembre\ 2024\ au\ 14\ dÃ©cembre\ 2024_V20242910.pdf
```

gets you something pretty good that you can access by line / character number


where it fails, use the Microsoft Excel mobile app to take a photograph (button in bottom left) and extract the tables. (really)
