# Code

The following is the lung cancer plandefinition as of August 17, 2021. It worked. Here's some commentary.



```
{
  "resourceType": "PlanDefinition",
  "id": "plandefinition-ONLungCancerScreening",
  "url": "http://fhir.org/guides/purajuniper/plandefinition/plandefinition-ONLungCancerScreening",
  ```

  The URLs throughout every file don't need to actually resolve, they just need to match between references.

  ```
  "identifier": [
    {
      "use": "official",
      "value": "LungCancerScreening"
    }
  ],
  "version": "0.1",
  "name": "LungCancerScreening",
  "title": "LungCancerScreening",
  ```

  I don't think it makes a difference, but I kept the identifiers, names, and titles to always be the same, just to make it easier for me.

```
  "type": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/plan-definition-type",
        "code": "eca-rule",
        "display": "ECA Rule"
      }
    ]
  },

  ```

  The type came with the HTNU plandefinition, I kept it. 

  ```
  "status": "draft",
  "date": "2020-02-04T00:00:00-08:00",
  "publisher": "Cancer Care Ontario",
  "description": "This PlanDefinition identifies eligibility for lung cancer screening",
  "purpose": "The purpose of this is to test the system to make sure we have complete end-to-end functionality",
  "usage": "This is to be used in conjunction with a patient-facing FHIR application.",
  "useContext": [
    {
      "code": {
        "system": "http://hl7.org/fhir/usage-context-type",
        "code": "focus",
        "display": "Clinical Focus"
      },
      "valueCodeableConcept": {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "93880001",
            "display": "Primary malignant neoplasm of lung"
          }
        ]
      }
    }
  ],

```

The usecontext here consists of a code and a VCC. the Code specifies the focus as being clinical, and the VCC selects uses a snomed code for lung cancer. 

```
  "jurisdiction": [
    {
      "coding": [
        {
          "system": "urn:iso:std:iso:3166",
          "code": "CA",
          "display": "Canada"
        }
      ]
    }
  ],
  "topic": [
    {
      "text": "Lung Cancer Screening eligibility"
    }
  ],
  "copyright": "© Cancer Care Ontario 2021",  
  ```

Always verify copyright and jurisdiction for administrative purposes.

  ```
  "library": "http://fhir.org/guides/purajuniper/ONLungCancerScreening/Library/LungCancerScreening",
  ```

  Just like the  url, the library doesn't need to resolve, just to be consistent.

  ```
  "action": [
  
    {
      "title": "Lung Cancer Screening",
      "documentation": [
        {
          "type": "documentation",
          "display": "Ontario's Lung Cancer Screening Pathway",
          "url": "https://www.cancercareontario.ca/en/pathway-maps/lung-cancer"
        }
      ],
      "trigger": [
        {
          "type": "named-event",
          "name": "patient-view"
        }
      ],
      "condition": [
        {
          "kind": "start",
          "expression": {
            "language": "text/cql",
            "expression": "'true'"
          }
        }
      ],
      "dynamicValue": [
        {
          "path": "action.description",
          "expression": {
            "description": "Patient Name.",
            "language": "text/cql",
            "expression": "Patient Name"
          }
        },
        {
          "path": "action.extension",
          "expression": {
            "language": "text/cql",
            "expression": "Info"
          }
        }
      ],

```

The top action is the action for the actual execution of the CQL contained in the library file. 

```
      "action": [
        {
          "title": "Recommendation",
          "description": "Determines type of recommendation regarding status of Lung Cancer Screening eligibility.",
          "condition": [
            {
              "kind": "applicability",
              "expression": {
                "description": "Determine if Patient is eligible for screening.",
                "language": "text/cql",
                "expression": "MeetsInclusionCriteria"
              }
            }
          ],
          "dynamicValue": [
            {
              "path": "action.title",
              "expression": {
                "description": "Determines if and what type of recommendation patient should be recommended.",
                "language": "text/cql",
                "expression": "Recommendation"
              }
            },
            {
              "path": "action.description",
              "expression": {
                "description": "Rationale for recommendation type.",
                "language": "text/cql",
                "expression": "Rationale Combined Data"
              }
            },
            {
              "path": "action.extension",
              "expression": {
                "language": "text/cql",
                "expression": "Indicator Status"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

This second action is an element of the first one, and it contains the returning of the CDS data from the CQL.