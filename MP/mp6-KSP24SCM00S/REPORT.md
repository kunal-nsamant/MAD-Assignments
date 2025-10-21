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
- [X] There are at least 3 separate screens/pages in the app
- [X] There is at least one stateful widget in the app, backed by a custom model
      class using a form of state management
- [X] Some user-updateable data is persisted across application launches
- [X] Some application data is accessed from an external source and displayed in
      the app
- [X] There are at least 5 distinct unit tests, 5 widget tests, and 1
      integration test group included in the project

## Questionnaire

Answer the following questions, briefly, so that we can better evaluate your
work on this machine problem.

1. What does your app do?

   MovieMate is a movie browsing and management application that allows users to discover popular and top-rated movies. Users can browse movies with pagination, view detailed information about each movie, add movies to their favorites list, and sort their favorites. The app features a modern dark theme with responsive design that adapts to different screen sizes.

2. What external data source(s) did you use? What form do they take (e.g.,
   RESTful API, cloud-based database, etc.)?

   The app uses The Movie Database (TMDB) RESTful API (api.themoviedb.org) to fetch movie data. It accesses endpoints for popular movies, top-rated movies, and individual movie details. The API returns JSON data including movie titles, descriptions, ratings, release dates, and poster images.

3. What additional third-party packages or libraries did you use, if any? Why?

   The app uses the standard Flutter packages provided in pubspec.yaml: 'http' for API requests, 'provider' for state management, 'shared_preferences' for local data persistence, and testing packages ('flutter_test', 'integration_test', 'mockito') for comprehensive testing. No additional third-party packages were added.

4. What form of local data persistence did you use?

   The app uses SharedPreferences to persist user favorites, favorite timestamps, and sorting preferences locally. This allows favorite movies and user settings to be maintained across app restarts. The data is stored as JSON strings and automatically loaded when the app starts.

5. What workflow is tested by your integration test?

   The integration tests cover 4 core user workflows: (1) Home screen displaying movies correctly with proper UI elements, (2) Complete favorites functionality - adding movies to favorites by tapping heart buttons and removing them with visual feedback, (3) Navigation workflow from home screen to favorites screen via the app bar heart button, and (4) Category switching between popular and top-rated movies with toggle button functionality. Mock providers are used to simulate API responses without making real network calls during testing.

## Summary and Reflection

Being a movie enthusiast, I was really excited to build an IMDb-style app using TMDB's API. It felt great working on something I'd genuinely want to use. For this project, I focused on several key implementation decisions that I thought would make the app stand out. After seeing how well Provider worked in our class demos, I went with that for state management. I also spent quite a bit of time on responsive design to make sure it looked good on different screen sizes, and chose a dark theme with that signature IMDb yellow color (#F5C518) for branding. Some other features I'm proud of include the pagination system that handles TMDB's API quirks, persistent favorites using SharedPreferences (just like we learned in class), and custom UI touches like the color-coded rating badges and movie numbering. I made sure to include proper error handling and loading states throughout, plus wrote a solid test suite using mock providers so the tests run without hitting the actual API.

This was definitely my favorite project of the semester since it was the final one where I could pull together everything from MPs 1 to 5. Those demo examples from lecture were a important aspect, especially the SharedPreferences and API handling parts that I used heavily here. It's really satisfying how all the concepts we covered throughout the course came together in this project, from managing state to writing comprehensive tests.
