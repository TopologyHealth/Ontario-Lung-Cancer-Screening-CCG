# Ontario-Lung-Cancer-Screening-CCG

##Introduction

This is a guideline to determine patient eligibility for lung cancer screening, according to Cancer Care Ontario.


##Testing and File Structure##
Any test data will need one of two observations: Either Pack/Day (LOINC 8663-7) or Smoking Status (LOINC 72166-2). Every Smoking
Status observation must contain a valueCodeableConcept of a former or current smoker (SNOMED 8517006 or 77176002). 

**DO NOT PUT ANY INFORMATION INSIDE COMPONENTS**


The file structure is adapted from the HTNU18IG, and will follow the following format:

input
|-- cql
    |-- LungCancerScreening.cql
    |-- CQL of any included libraries
|-- resources
    |-- library
       |-- library-LungCancerScreening.json
       |-- Any included libraries
|-- tests
    |-- LungCancerScreening
        |-- Patient1
            |-- Patient1.json
            |-- observation1.json
            |-- observation2.json
            |-- ...
        |-- Patient2
            |-- ...
        |-- Patient3
            |--
        |-- ...
|-- pagecontent
    |-- plandefinition
        |- plandefinition-LungCancerScreening.json `(Not yet implemented)`




## Links

https://www.cancercareontario.ca/sites/ccocancercare/files/assets/LungCancerDiagnosisPathwayMap.pdf
