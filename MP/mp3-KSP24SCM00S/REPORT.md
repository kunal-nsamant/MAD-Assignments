# MP Report

## Personal Information

- Name: Kunal Nilesh Samant
- AID: A20541900

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The app builds without error
- [X] I tested the app in at least one of the following platforms (check all
      that apply):
  - [X] iOS simulator / MacOS
  - [ ] Android emulator
  - [X] Google Chrome
- [X] The dice rolling mechanism works correctly
- [X] The scorecard works correctly
- [X] Scores are correctly calculated for all categories
- [X] The game end condition is correctly implemented, and the final score is
      correctly displayed
- [X] The game state is reset when the user dismisses the final score
- [X] The implementation separates layout from data, involving the use of data
      model classes separate from custom widgets

## Summary and Reflection

I built a single-player Yahtzee game using Flutter as required, keeping the logic (like dice rolls, scoring, and game state) separate from the UI by using model classes such as Dice and ScoreCard. I used StatefulWidget to manage state, and everything from rolling dice to selecting score categories works smoothly. I also added a welcome screen with a loading bar to give the app a clean and polished start. All score categories function as expected — dice roll randomly, players can hold them, scores are calculated correctly, and once all categories are filled, the game ends with a final score and an option to restart.

I'm starting to understand Flutter much better as I work with it more. I can say this was the first game I built in flutter, previously I used Andriod Developement which has more work and hassle than this. It was great to see the game take shape visually as I put each part together. Flutter made it really convenient to manage both the design and the logic side by side. I'm happy with how everything turned out, the structure is clean, the game works end to end, and the whole experience feels complete.
