# MP Report

## Personal Information

- Name: Kunal Nilesh Samant
- AID: A20541900

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The simulator builds without error

- [X] The simulator runs on at least one configuration file without crashing

- [X] Verbose output (via the `-v` flag) is implemented

- [ ] I used the provided starter code

- The simulator runs correctly (to the best of my knowledge) on the provided
  configuration file(s):

  - [X] conf/sim1.yaml

  - [X] conf/sim2.yaml

  - [X] conf/sim3.yaml

  - [X] conf/sim4.yaml

  - [X] conf/sim5.yaml

## Implementation Decisions

I used separate classes for each process type (Singleton, Periodic, Stochastic) to keep things organized. The hardest part was getting the exponential distribution working correctly for stochastic processes - had to make sure the random seeds worked for consistent results. I implemented FIFO queueing and sorted events by arrival time. Also added error handling for bad inputs like negative numbers. Everything runs correctly and matches the expected outputs.

## Reflection

The math behind exponential distributions was tougher than I expected - had to look some stuff up online. But it was cool seeing how the theory from class actually works in practice. This project really helped me understand discrete event simulation instead of just memorizing formulas. The object-oriented approach saved me when things got complicated.

If I did this again, I'd spend more time understanding the math upfront before coding. I had to go back and fix some things because I didn't fully get exponential distributions at first. Overall though, pretty happy with how it turned out!
