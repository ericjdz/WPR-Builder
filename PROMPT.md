# Weekly Progress Report JSON Prompt

Use this prompt in ChatGPT or Claude to convert your weekly internship/activity notes into the JSON required by the WPR generator.

## Prompt to paste

```md
Convert my weekly progress details into valid JSON for a Weekly Progress Report generator.

Rules:
- Return JSON only.
- Follow the schema exactly.
- Use MM/DD/YYYY for `fromDate`, `toDate`, `preparedDate`, and `supervisorDate`.
- Use MM/DD/YY for each day `date`.
- Keep `days` to up to 5 entries per week.
- Keep each day’s `tasks` to the tasks explicitly described in my notes.
- Do not invent personal details.
- If I do not provide `totalRequiredHours`, use 250.
- If I do not provide `supervisorDate`, use the same value as `preparedDate`.
- Preserve concise, professional wording for task descriptions.

Schema:
```json
{
  "weeks": [
    {
      "department": "string",
      "weekNumber": 1,
      "internName": "string",
      "company": "string",
      "deptDeployed": "string",
      "supervisorName": "string",
      "fromDate": "MM/DD/YYYY",
      "toDate": "MM/DD/YYYY",
      "hoursThisWeek": 40,
      "totalHoursCompleted": 40,
      "totalRequiredHours": 250,
      "workSchedule": "string",
      "preparedDate": "MM/DD/YYYY",
      "supervisorDate": "MM/DD/YYYY",
      "days": [
        {
          "date": "MM/DD/YY",
          "timeIn": "string",
          "timeOut": "string",
          "hoursWorked": 8,
          "tasks": [
            {
              "description": "string",
              "hoursSpent": 2,
              "status": "100%"
            }
          ]
        }
      ]
    }
  ]
}
```

Field notes:
- `department`: The department heading shown at the top of the report.
- `weekNumber`: The report number.
- `internName`: Name of the student/intern.
- `company`: Host organization.
- `deptDeployed`: Assigned unit/team/department.
- `supervisorName`: Supervisor or immediate contact.
- `fromDate` / `toDate`: Coverage of the week.
- `hoursThisWeek`: Total hours worked within the week.
- `totalHoursCompleted`: Cumulative completed hours up to this report.
- `totalRequiredHours`: Total required internship hours.
- `workSchedule`: Usual schedule, e.g. `8:00 AM - 5:00 PM`.
- `preparedDate`: Date the intern signs/prepares the form.
- `supervisorDate`: Date beside the supervisor signature line.
- `days`: Up to 5 workdays for the week.
- `tasks[].description`: Clear professional summary of a single task.
- `tasks[].hoursSpent`: Time spent on that task.
- `tasks[].status`: Completion text, e.g. `100%`, `80%`, `Completed`, `Ongoing`.

My notes:
[PASTE YOUR WEEKLY DETAILS HERE]
```

## Example source notes

```md
Week 3
Department: Department of Information Systems
Intern: Your Name
Company: Your Company
Assigned team: Systems Support Unit
Supervisor: Supervisor Name
Week covered: 05/19/2026 to 05/23/2026
Schedule: 8:00 AM - 5:00 PM
Prepared date: 05/23/2026
Total completed hours so far: 120

Monday 05/19/26, 8:00 AM to 5:00 PM, 8 hours
- Organized support tickets and classified recurring issues, 3 hours, 100%
- Updated shared documentation for resolved concerns, 3 hours, 100%
- Joined a team huddle and listed next actions, 2 hours, 100%

Tuesday 05/20/26, 8:00 AM to 5:00 PM, 8 hours
- Reviewed request logs and prepared summaries, 4 hours, 100%
- Assisted with routine records cleanup, 4 hours, 100%
```

## Example JSON output

```json
{
  "weeks": [
    {
      "department": "Department of Information Systems",
      "weekNumber": 3,
      "internName": "Your Name",
      "company": "Your Company",
      "deptDeployed": "Systems Support Unit",
      "supervisorName": "Supervisor Name",
      "fromDate": "05/19/2026",
      "toDate": "05/23/2026",
      "hoursThisWeek": 40,
      "totalHoursCompleted": 120,
      "totalRequiredHours": 250,
      "workSchedule": "8:00 AM - 5:00 PM",
      "preparedDate": "05/23/2026",
      "supervisorDate": "05/23/2026",
      "days": [
        {
          "date": "05/19/26",
          "timeIn": "8:00 AM",
          "timeOut": "5:00 PM",
          "hoursWorked": 8,
          "tasks": [
            {
              "description": "Organized support tickets and classified recurring issues.",
              "hoursSpent": 3,
              "status": "100%"
            },
            {
              "description": "Updated shared documentation for resolved concerns.",
              "hoursSpent": 3,
              "status": "100%"
            },
            {
              "description": "Joined a team huddle and listed next actions.",
              "hoursSpent": 2,
              "status": "100%"
            }
          ]
        },
        {
          "date": "05/20/26",
          "timeIn": "8:00 AM",
          "timeOut": "5:00 PM",
          "hoursWorked": 8,
          "tasks": [
            {
              "description": "Reviewed request logs and prepared summaries.",
              "hoursSpent": 4,
              "status": "100%"
            },
            {
              "description": "Assisted with routine records cleanup.",
              "hoursSpent": 4,
              "status": "100%"
            }
          ]
        }
      ]
    }
  ]
}
```
