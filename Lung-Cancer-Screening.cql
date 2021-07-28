library "Lung-Cancer-Screening" version '1.0.0'
using FHIR version '4.0.0'
include "FHIRHelpers" version '4.0.0' called FHIRHelpers
codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMED": 'http://snomed.info/sct'

code "PACKS A DAY": '8663-7' from "LOINC" display 'packs per day'
code "Tobacco smoking status code": '72166-2' from "LOINC" display 'Tobacco smoking status'
code "Ex-smoker (finding) code": '8517006' from "SNOMED" display 'Ex-smoker (finding)'
code "Smoker (finding) code": '77176002' from "SNOMED" display 'Smoker (finding)'
code "Cigarettes smoked current (pack per day) - Reported code": '8663-7' from "LOINC" display 'Cigarettes smoked current (pack per day) - Reported'
code "Malignant tumor of lung (disorder) code": '363358000' from "SNOMED" display 'Malignant tumor of lung (disorder)'

context Patient

define "generic_observation_concepts":
  [Observation: "Tobacco smoking status code"]
  union [Observation: "Cigarettes smoked current (pack per day) - Reported code"]

define "Most recent tobacco smoking status":
  MostRecent([Observation: "Tobacco smoking status code"])

define "Former smoker":
  exists([Observation: "Ex-smoker (finding) code"])

define "Current Smoker":
  exists([Observation: "Smoker (finding) code"])

define "Patient Age between 55 and 74":
  AgeInYears() >= 55 and AgeInYears() <= 74

define "Cigarettes smoked current (pack per day) - Reported":
  [Observation: "Cigarettes smoked current (pack per day) - Reported code"]


define "No Lung Cancer":
  not(exists([Condition: "Malignant tumor of lung (disorder) code"]))


define "Most recent Packs A Day observation":
  MostRecent([Observation: "PACKS A DAY"])

define "PacksPerDay":
  "Most recent Packs A Day observation" o
    return o.value


define "Pack-years":
  "Most recent tobacco smoking status" O
     let DurationInDays: duration in days of O.effective
     return System.Quantity { value: Round(("PacksPerDay" * (DurationInDays / 365.25)).value), unit: '{Pack-years}' }


define "PacksPerYear >=20":
  "Pack-years" >= 20 '{Pack-Years}'

define "Current or former smoker":
  "Former smoker"
  or "Current Smoker"

define "MeetsInclusionCriteria":
  "Current or former smoker"
  and "Patient Age between 55 and 74"
  and "PacksPerYear >=20"

define "InPopulation":
   "MeetsInclusionCriteria"



define function Verified(ObsList List<Observation>):
  ObsList O where O.status.value in {'final', 'corrected', 'amended'}

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
