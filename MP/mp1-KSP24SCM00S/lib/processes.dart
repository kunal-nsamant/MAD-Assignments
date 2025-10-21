// lib/processes.dart
import 'util/stats.dart';

/// Represents a single event that happens in our queueing system
class Event {
  final String processName;
  final int arrivalTime;
  final int duration;
  
  // These get filled in during the simulation
  int? startTime;
  int? waitTime;
  
  Event(this.processName, this.arrivalTime, this.duration);
  
  @override
  String toString() {
    return 'Event(process: $processName, arrival: $arrivalTime, duration: $duration)';
  }
}

/// Base class that all different process types inherit from
abstract class Process {
  final String processName;
  
  Process(this.processName);
  
  /// Each process type implements this differently to create their events
  List<Event> generateEvents();
}

/// This creates just one event with fixed timing - the simplest type
class SingletonProcess extends Process {
  final int eventDuration;
  final int eventArrivalTime;
  
  SingletonProcess(String name, this.eventDuration, this.eventArrivalTime) : super(name);
  
  @override
  List<Event> generateEvents() {
    // Just return one event
    return [Event(processName, eventArrivalTime, eventDuration)];
  }
}

/// Creates multiple events that happen at regular intervals
class PeriodicProcess extends Process {
  final int jobDuration;
  final int timeBetweenArrivals;
  final int firstJobArrival;
  final int howManyJobs;
  
  PeriodicProcess(String name, this.jobDuration, this.timeBetweenArrivals, 
                  this.firstJobArrival, this.howManyJobs) : super(name);
  
  @override
  List<Event> generateEvents() {
    List<Event> eventsList = [];
    
    // Create the specified number of events at regular intervals
    for (int jobNumber = 0; jobNumber < howManyJobs; jobNumber++) {
      int whenThisJobArrives = firstJobArrival + (jobNumber * timeBetweenArrivals);
      eventsList.add(Event(processName, whenThisJobArrives, jobDuration));
    }
    
    return eventsList;
  }
}

/// Creates random events using exponential distribution - most realistic type
class StochasticProcess extends Process {
  final double averageDuration;
  final double averageTimeBetweenArrivals;
  final int firstEventTime;
  final int simulationEndTime;
  late final ExpDistribution _durationRandomizer;
  late final ExpDistribution _arrivalTimeRandomizer;
  
  StochasticProcess(String name, this.averageDuration, this.averageTimeBetweenArrivals,
                   this.firstEventTime, this.simulationEndTime, {int? seed}) : super(name) {
    // Set up the random number generators with different seeds for variety
    _durationRandomizer = ExpDistribution(meanValue: averageDuration, seed: seed);
    _arrivalTimeRandomizer = ExpDistribution(meanValue: averageTimeBetweenArrivals, seed: seed != null ? seed + 1 : null);
  }
  
  @override
  List<Event> generateEvents() {
    List<Event> randomEventsList = [];
    double currentSimulationTime = firstEventTime.toDouble();
    
    // Keep generating events until we reach the end time
    while (currentSimulationTime < simulationEndTime) {
      // Getting a random duration from our exponential distribution
      int randomDuration = _durationRandomizer.next().round();
      if (randomDuration <= 0) randomDuration = 1; // Making sure we don't get zero or negative duration
      
      randomEventsList.add(Event(processName, currentSimulationTime.round(), randomDuration));
      
      // Figuring out when the next event will arrive
      double randomInterarrivalTime = _arrivalTimeRandomizer.next();
      if (randomInterarrivalTime <= 0) randomInterarrivalTime = 0.1; // Avoiding zero gaps between events
      currentSimulationTime += randomInterarrivalTime;
    }
    
    return randomEventsList;
  }
}