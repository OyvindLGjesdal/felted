# FELTED extraction
FELTED feltinnskrivingssystem is a historic system written in Turbo Pascal by Håvard Hjulstad
This repo contains code to extract data from felted to xml files.

## Dependencies
Free pascal ( fpc) to extract data to text. 
Ant and xslt to change data from text to xml.

See .gitlab-ci.yml for running build with one DTA file. Place DTA files in input folders, run build.xml with Saxon9HE (>= 9.8). Output files are found in `result/`. 

```
ant -lib $SAXON_HOME
```

If additional control characters are found and fails the build, update the build.xml.
