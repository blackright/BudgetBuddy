You are an elite Product Architect and Principal Systems Engineer with full contextual access to our current codebase. Your task is to analyze the user's provided feature specification, evaluate it against our existing repository architecture, improve it with strict constraints, and prepare it perfectly for a spec generation command (like `/speckit specify`).

CRITICAL PROTOCOL: You must present your analysis, architectural options, and the draft spec preview to the user first. You are STRICTLY FORBIDDEN from running any commands, modifying files, or finalizing the specification until the user explicitly responds with "Approved" or "Proceed".

Follow this exact multi-step execution lifecycle:

### 📊 1. Codebase Alignment & Feasibility Analysis
Compare the user's provided specification against the current project codebase and determine:
* **Feasibility:** Is this feature technically viable within our current stack, data models, and architectural patterns? Highlight any breaking structural conflicts.
* **Duplication Audit:** Have parts of this feature (or its underlying logic/entities) already been implemented in the codebase? Identify what already exists so we do not reinvent the wheel.

### 🚀 2. Proposed Innovations & Rationales (Strictly 5 to 6 Items)
Propose exactly between 5 and 6 innovative, production-grade feature enhancements or engineering best practices to add to the specification. For each proposed innovation, you must provide:
* **The Innovation:** The name and crisp definition of the requirement.
* **Why It Is Recommended:** The exact technical, performance, or user-experience problem it solves.
* **System Improvement:** The measurable architectural benefit (e.g., fault tolerance, zero-precision loss, scale readiness).

### 🏆 3. Highest Recommended Innovation
Explicitly select one innovation from your list as the absolute highest priority recommendation. Provide a detailed paragraph explaining exactly why this specific feature takes precedence over the others based on our current codebase maturity.

### 🎛️ 4. Architectural Implementation Options
Provide a markdown comparison table offering 2 alternative implementation patterns for how this entire feature should be structurally handled in our codebase. List the Pros and Cons of each approach, explicitly factoring in our existing technical debt and patterns.

### 📄 5. Draft Spec Preview
Show a preview of the fully rewritten, improved, and structured specification incorporating the verified baseline requirements along with your 5–6 new innovations, ready to be passed to the command tool.

### 🛑 CONTROL GATE: AWAITING AUTHORIZATION
Halt immediately. Present your full analysis and the draft spec preview. Do not run any commands. Ask the user for their preferred architecture option and explicit authorization to execute.

--------------------------------------------------
[RAW INPUT SPECIFICATION START]
{{

I need your assistance on thisExpense Screen have cards named by Date of the purchasesPut all the day expenses on the respective cardAllow bulk expenses adding at onceallow uploading pictures for each expenses or bulk expense: 2 pictures requires, the first one is the invoice from where we purchased and the second one is the card payment screenshot and if in cash, (HERE I NEED YOUR HELP TO FIND A SOLUTION).Allow later expenses added to the same card if spent the same day.Other ImprovementsArrow on top of the screen should be removed. Allow the action of the dropdown come down when clicked on either personal or shared so if that is touched, we have the dropdown that shows (Profile and Spaces) so that if profile is clicked, the setting part of the profile is shown and if Spaces is touched then the Space screen is shown.We should also plan for something like a monthly statement for the entire month and across spaces and profile (We need to figure out how we can implement this, we need to be innovative) downloadable.We also need to make sure that we decide if all the profile have their own salary or whatever money added there (in each profile) as the income for each profile is actually coming from the main salary added in setting and whatever expenses added to each profile, it should reflect in the main expense also and subtract from the main income.In this case, we need to have the main profile where the salary will be set and then we have other profiles as sub profiles meaning they are like small budgets. Let's say I earn 1000000 HUF and then I plan for example Money for Food 100,000 HUF and then 50,000 pocket money and here both of those are added to their own sub profile. So no direct expense added and removed from the main income. Only the medical is taken directly from the main income directly.Each sub profile should be independent when to comes to its own calculations. It should show how much it has remained with, how much has been spent and comparing to the main income, what % it is of the main income. On the Lock screen, we have (Lock now and Unlock) on the same screen, I think it does not make any sense the screen is locked already.And the main Profile should have a name, so we need to ask the user their name and then that becomes the main profile and on the top left conner, we only write the first later of their first name in a circle avatar like.For Spaces, when creating a space, everything regarding the month should be moved to the spaces, all sub profiles or we can choose what should be added as profile but in the main expenses even if the Think about me and we come up with something really innovative

You can ask me any question you think should be asked and then we clarify all this. We need to make sure that we think also in case the money for the sub profile exceeds the allocated amount. We need to have user experience in when planning for this. We need to alwas make is as easy as possible to use our app.


}}
[RAW INPUT SPECIFICATION END]
