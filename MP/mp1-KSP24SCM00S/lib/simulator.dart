// lib/simulator.dart
import 'package:yaml/yaml.dart';
import 'processes.dart';

/// Main simulator class that handles the queueing system
class Simulator {
  final bool showDetailedOutput;
  final List<Process> processList = [];
  final List<Event> finishedEvents = [];
  
  Simulator(YamlMap configurationData, {this.showDetailedOutput = false}) {
    _loadConfigurationFromYaml(configurationData);
  }
  
  // This method reads the YAML config and creates different types of processes
  void _loadConfigurationFromYaml(YamlMap configurationData) {
    int processCounter = 0; // Keep track of process order for seed generation
    
    for (final processName in configurationData.keys) {
      final processConfig = configurationData[processName];
      final String currentProcessName = processName.toString();
      
      // Checks what type of process we need to create based on the config
      switch (processConfig['type']) {
        case 'singleton':
          // Single event that happens once
          processList.add(SingletonProcess(
            currentProcessName,
            processConfig['duration'],
            processConfig['arrival']
          ));
          break;
          
        case 'periodic':
          // Events that repeat at regular intervals
          processList.add(PeriodicProcess(
            currentProcessName,
            processConfig['duration'],
            processConfig['interarrival-time'],
            processConfig['first-arrival'],
            processConfig['num-repetitions']
          ));
          break;
          
        case 'stochastic':
          // Random events using exponential distribution
          // I'm using different seeds for each process to make sure we get consistent but varied results
          processList.add(StochasticProcess(
            currentProcessName,
            processConfig['mean-duration'].toDouble(),
            processConfig['mean-interarrival-time'].toDouble(),
            processConfig['first-arrival'],
            processConfig['end'],
            seed: processCounter * 1000 + 42 // Using a formula to make seeds predictable but different
          ));
          break;
          
        default:
          throw ArgumentError('I don\'t recognize this process type: ${processConfig['type']}');
      }
      processCounter++;
    }
  }
  
  // Main simulation logic - this is where the magic happens
  void run() {
    // First, get all events from every process
    List<Event> allEventsToProcess = [];
    for (Process currentProcess in processList) {
      allEventsToProcess.addAll(currentProcess.generateEvents());
    }
    
    // Sort events by when they arrive, and if they arrive at the same time, sort by name
    // This ensures we process events in the right order
    allEventsToProcess.sort((eventA, eventB) {
      int arrivalTimeComparison = eventA.arrivalTime.compareTo(eventB.arrivalTime);
      if (arrivalTimeComparison != 0) return arrivalTimeComparison;
      return eventA.processName.compareTo(eventB.processName);
    });
    
    if (showDetailedOutput) {
      print('# Simulation trace\n');
    }
    
    int serverTime = 0; // This tracks when the server will be free
    
    // Now process each event one by one
    for (Event currentEvent in allEventsToProcess) {
      // Figure out if the event has to wait or can start immediately
      if (currentEvent.arrivalTime > serverTime) {
        // Server is free, so no waiting needed
        serverTime = currentEvent.arrivalTime;
        currentEvent.waitTime = 0;
      } else {
        // Server is busy, so the event has to wait
        currentEvent.waitTime = serverTime - currentEvent.arrivalTime;
      }
      
      currentEvent.startTime = serverTime;
      serverTime += currentEvent.duration; // Update when server will be free again
      
      if (showDetailedOutput) {
        String waitMessage = currentEvent.waitTime == 0 ? 'no wait' : 'waited ${currentEvent.waitTime}';
        print('t=${currentEvent.startTime}: ${currentEvent.processName}, duration ${currentEvent.duration} started (arrived @ ${currentEvent.arrivalTime}, $waitMessage)');
      }
      
      finishedEvents.add(currentEvent);
    }
    
    if (showDetailedOutput) {
      print('\n--------------------------------------------------------------\n');
    }
  }
  
  // Generate and print the final report with statistics
  void printReport() {
    // First show statistics for each process separately
    print('# Per-process statistics\n');
    
    // Group events by which process they came from, keeping the original order
    Map<String, List<Event>> eventsGroupedByProcess = {};
    List<String> processNamesInOrder = [];
    
    for (Event currentEvent in finishedEvents) {
      if (!eventsGroupedByProcess.containsKey(currentEvent.processName)) {
        processNamesInOrder.add(currentEvent.processName);
        eventsGroupedByProcess[currentEvent.processName] = [];
      }
      eventsGroupedByProcess[currentEvent.processName]!.add(currentEvent);
    }
    
    // Calculate and print stats for each process
    for (String processName in processNamesInOrder) {
      List<Event> eventsFromThisProcess = eventsGroupedByProcess[processName]!;
      int totalWaitingTime = eventsFromThisProcess.fold(0, (runningSum, event) => runningSum + event.waitTime!);
      double averageWaitingTime = eventsFromThisProcess.isEmpty ? 0.0 : totalWaitingTime / eventsFromThisProcess.length;
      
      print('$processName:');
      print('  Events generated:  ${eventsFromThisProcess.length}');
      print('  Total wait time:   $totalWaitingTime');
      print('  Average wait time: ${averageWaitingTime.toStringAsFixed(2)}');
      print('');
    }
    
    print('--------------------------------------------------------------\n');
    
    // Now show overall summary statistics
    print('# Summary statistics\n');
    
    int totalNumberOfEvents = finishedEvents.length;
    double grandTotalWaitTime = finishedEvents.fold(0.0, (sum, event) => sum + event.waitTime!);
    double overallAverageWaitTime = totalNumberOfEvents == 0 ? 0.0 : grandTotalWaitTime / totalNumberOfEvents;
    
    print('Total num events:  $totalNumberOfEvents');
    print('Total wait time:   ${grandTotalWaitTime.toStringAsFixed(1)}');
    print('Average wait time: ${overallAverageWaitTime.toStringAsFixed(3)}');
  }
}