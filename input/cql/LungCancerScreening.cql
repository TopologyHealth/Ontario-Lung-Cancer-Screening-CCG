library LungCancerScreening version '1.0.0'
using FHIR version '4.0.0'
include "FHIRHelpers" version '4.0.0' called FHIRHelpers
codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMED": 'http://snomed.info/sct'

code "PACKS A DAY": '8663-7' from "LOINC" display 'packs per day'
code "Tobacco smoking status code": '72166-2' from "LOINC" display 'Tobacco smoking status'
code "Ex-smoker (finding) code": '8517006' from "SNOMED" display 'Ex-smoker (finding)'
code "Smoker (finding) code": '77176002' from "SNOMED" display 'Smoker (finding)'
code "Malignant tumor of lung (disorder) code": '363358000' from "SNOMED" display 'Malignant tumor of lung (disorder)'

context Patient


define "Most recent tobacco smoking status":
  MostRecent([Observation: "Tobacco smoking status code"])

define "Former smoker":
"Most recent tobacco smoking status" O
  where (O.value as CodeableConcept) ~ "Ex-smoker (finding) code"

define "Current Smoker":
"Most recent tobacco smoking status" O
  where (O.value as CodeableConcept) ~ "Smoker (finding) code"

define "Patient Age between 55 and 74":
  AgeInYears() >= 55 and AgeInYears() <= 74


//Makes sure that there are no lung cancer conditions
define "No Lung Cancer":
  not(exists([Condition: "Malignant tumor of lung (disorder) code"]))

//Takes the most recent observation contained as packs a day
define "Most recent Packs A Day observation":
  MostRecent([Observation: "PACKS A DAY"])

define "PacksPerDay":
  "Most recent Packs A Day observation" o
    return FHIRHelpers.ToQuantity(o.value)

//calculates pack-years includes units
define "Pack-years":
  "Most recent tobacco smoking status" O
     let DurationInDays: duration in days of O.effective
     return System.Quantity { value: Round(("PacksPerDay" * (DurationInDays / 365.25)).value), unit: '{Pack-Years}' }


define "PacksYears >=20":
  "Pack-years" >= 20 '{Pack-Years}'
//verifies current or former smoker
define "Current or former smoker":
  "Former smoker" is not null
  or "Current Smoker" is not null



//Checks to see if the patient is in the criteria
define "MeetsInclusionCriteria":
  "Current or former smoker"
  and "Patient Age between 55 and 74"
  and "PacksYears >=20"



define function Verified(ObsList List<Observation>):
  ObsList O where O.status.value in {'final', 'corrected', 'amended'}

//Defined by the CDS authoring tool, don't ask me
define function MostRecent(ObsList List<Observation>):
  Last(ObsList O sort by Coalesce(
    (effective as FHIR.dateTime).value,
    (effective as FHIR.instant).value,
    (effective as FHIR.Period)."end".value,
    (effective as FHIR.Period)."start".value,
    issued.value)
  )

define function HighestObservation(ObsList List<Observation>):
  Max(ObsList O return FHIRHelpers.ToQuantity(O.value as FHIR.Quantity))




//All the cds definitions

  define "Recommendation":
      if "MeetsInclusionCriteria" then 'Patient applicable for lung cancer screening.'
      else 'Patient not applicable for lung cancer screening.'

    define "Rationale Combined Data":
      "Rationale" + ';' + "Source" + ';' + "Suggestions" + ';' + "Selection Behavior"

    define "Rationale":
      if "MeetsInclusionCriteria" then 'The patient is a current or former smoker between the ages of 55 and 74 with over 20 pack-years'
      else 'No Further Action Required.'

    define "Indicator Status":
      if "MeetsInclusionCriteria" then "Info"
      else "Info"


    define "Source":
      if "MeetsInclusionCriteria" then 'https://www.cancercareontario.ca/sites/ccocancercare/files/assets/LungCancerDiagnosisPathwayMap.pdf'
      else ''

    define "Suggestions":
      if "MeetsInclusionCriteria" then ''
      else ''

    define "Selection Behavior":
      if "MeetsInclusionCriteria" then 'at-most-one'
      else 'at-most-one'


//we deleted links because it was redundant

  define "Info":
    'info'

  define "Warning":
    'warning'

  define "Critical":
    'critical'

  define "Errors":
    null
