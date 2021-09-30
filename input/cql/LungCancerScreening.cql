library LungCancerScreening version '1.0.0'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMED": 'http://snomed.info/sct'

valueset "LungCancerValueSet": 'http://fhir.org/guides/purajuniper/valueset/valueset-ONLungCancerScreening'

code "PACKS A DAY": '8663-7' from "LOINC" display 'packs per day'
code "Tobacco smoking status code": '72166-2' from "LOINC" display 'Tobacco smoking status'
code "Ex-smoker (finding) code": '8517006' from "SNOMED" display 'Ex-smoker (finding)'
code "Smoker (finding) code": '77176002' from "SNOMED" display 'Smoker (finding)'
code "Malignant tumor of lung (disorder) code": '363358000' from "SNOMED" display 'Malignant tumor of lung (disorder)'
code "Suspected Lung Cancer code": '162573006' from "SNOMED" display 'Suspected Lung Cancer'
code "Hemoptysis code": '66857006' from "SNOMED" display 'Hemoptysis'
code "Unexplained Weight Loss code": '422868009' from "SNOMED" display 'Unexplained Weight Loss'
code "Weight Loss code": '816160009' from "SNOMED" display 'Weight Loss'

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

define "Patient Name":
  First(Patient.name.given)
   + ' ' +
  First(Patient.name.family)


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
     return System.Quantity { value: Round(("PacksPerDay" * (DurationInDays / 365.25)).value), unit: '{PackYears}' }


define "PacksYears >=20":
  "Pack-years" >= 20 '{PackYears}'
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

// Exclusion criteria
define function MostRecent(ConList List<Condition>):
  Last(ConList C sort by
    (recordedDate as FHIR.dateTime).value
    )

// diagnosed with lung cancer
define "Has Lung Cancer":
  exists([Condition: "Malignant tumor of lung (disorder) code"])

// under surveillance for lung nodules
define "Suspected Lung Cancer":
  exists([Condition: "Suspected Lung Cancer code"])

// had hemoptysis of unknown cause or unexplained weight loss of more than 5kg in the past year
define "Had hemoptysis of unknown cause":
  exists([Condition: "Hemoptysis code"])

define "Most recent unexplained weight loss":
  MostRecent([Condition: "Unexplained Weight Loss code"])

define "Had unexplained weight loss in the past year":
  "Most recent unexplained weight loss" C
    let I: Interval[FHIRHelpers.ToDateTime(C.recordedDate as FHIR.dateTime), FHIRHelpers.ToDateTime(C.recordedDate as FHIR.dateTime)]
    return I ends 1 years or less before Today()

define "Most recent weight loss observation":
  MostRecent([Observation: "Weight Loss code"])

define "Had weight loss of over 5kg":
  "Most recent weight loss observation" O
  return O.value >= 5 'kg'
// TODO: find weight loss within the past year only

define "Had hemoptysis of unknown cause or unexplained weight loss of more than 5kg in the past year":
    "Had hemoptysis of unknown cause"
    or (
      "Had unexplained weight loss in the past year"
      and "Had weight loss of over 5kg"
    )

// undergoing assessment, treatment, or surveillance for life-threatening conditions

define "MeetsExclusionCriteria":
    "Has Lung Cancer"
    or "Suspected Lung Cancer"
    or "Had hemoptysis of unknown cause or unexplained weight loss of more than 5kg in the past year"

// if current smoker and no other exclusion criteria, then refer to smoking cessation
//  regardless of whether they are in the age bracket or not
define "Refer to smoking cessation":
  "Current Smoker" is not null
  and not "MeetsExclusionCriteria"

//All the cds definitions

//Next step: automatically generate that referral
  define "Recommendation":
      if "MeetsInclusionCriteria" then 'Patient applicable for lung cancer screening.'
      else if "Refer to smoking cessation" then 'Patient not applicable for lung cancer screening, but should be referred to the smoking cessation program'
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
