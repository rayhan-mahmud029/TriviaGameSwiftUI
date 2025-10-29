# Project 5 - *Trivia Game*

Submitted by: **Rezwan Mahmud**

**Trivia Game** is an interactive quiz app that dynamically fetches questions from the **Open Trivia Database API**.  
Users can customize their quiz with different categories, difficulties, and question types, then test their knowledge against a countdown timer.  

Time spent: **8** hours spent in total

---

## Required Features

The following **required** functionality is completed:

- [x] App launches to an Options screen where user can modify the types of questions presented when the game starts. Users should be able to choose:
  - [x] Number of questions
  - [x] Category of questions
  - [x] Difficulty of questions
  - [x] Type of questions (Multiple Choice or True / False)
- [x] User can tap a button to start the trivia game, which presents questions and answers in a **card-based view**.
  - Hint: Implemented similar to FlashCard UI using `ScrollView` and custom `QuestionCard` views.
- [x] Selected choices are visually marked as the user taps their choice (highlighted before submission).
- [x] User can submit answers and view their total score at the end of the game.

---

## Optional Features

The following **optional** features are implemented:

- [x] User has answers marked as **correct (green)** or **incorrect (red)** after submitting.
- [x] A **timer** is displayed during the game and automatically submits the quiz when time runs out.
- [x] Smooth transitions between loading, game, and result states.
- [x] HTML entities (e.g., `&quot;`, `&#039;`) are decoded safely for clean question text.

---

## Additional Features

The following **additional** features are implemented:

- [x] Custom **QuestionCard** and **AnswerRow** reusable SwiftUI components.
- [x] Robust **MVVM architecture** using `@StateObject` and `@Published` for state updates.
- [x] Error-handled **async/await networking** with graceful fallback on API failure.
- [x] Real-time countdown using `Combine.Timer` that syncs with UI updates.
- [x] Responsive layout optimized for both iPhone 15 Pro and iPhone 17 Pro simulators.

---

## Video Walkthrough
<div>
    <a href="https://www.loom.com/share/225dfdd6fa574f6b8bf0605b871fa1f6">
    </a>
    <a href="https://www.loom.com/share/225dfdd6fa574f6b8bf0605b871fa1f6">
      <img style="max-width:300px;" src="https://cdn.loom.com/sessions/thumbnails/225dfdd6fa574f6b8bf0605b871fa1f6-fee18ce702d9ae57-full-play.gif">
    </a>
  </div>

---

## Notes

During development, one major challenge was handling **HTML entity decoding** safely from the Open Trivia API,  
as using `NSAttributedString(html:)` caused a **SIGABRT crash** on iOS 18 simulators.  
This was fixed by implementing a **manual decoder** for HTML entities, making the app 100% crash-free.

Another challenge was preventing **state mutation during SwiftUI rendering**,  
which was resolved by deferring ViewModel updates using `DispatchQueue.main.async`.

---

## License

    Copyright 2025 Rezwan Mahmud

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
