// bin/main.dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import '../lib/simulator.dart';

void main(List<String> arguments) {
  // Set up command line argument parsing
  final argumentParser = ArgParser()
    ..addOption('config', abbr: 'c', help: 'Configuration file path')
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose output', defaultsTo: false)
    ..addFlag('help', abbr: 'h', help: 'Show this help message', defaultsTo: false);

  try {
    final parsedArguments = argumentParser.parse(arguments);
    
    // Check if user wants to see help
    if (parsedArguments['help'] as bool) {
      print('Queueing System Simulator');
      print('Usage: dart run bin/main.dart -c <config_file> [-v]');
      print(argumentParser.usage);
      return;
    }
    
    // Get the config file path from command line
    final configurationFilePath = parsedArguments['config'] as String?;
    if (configurationFilePath == null) {
      print('Error: Configuration file path is required');
      print('Use -h for help');
      exit(1);
    }
    
    final shouldShowVerboseOutput = parsedArguments['verbose'] as bool;
    
    // Try to read and parse the YAML configuration file
    final configurationFile = File(configurationFilePath);
    if (!configurationFile.existsSync()) {
      print('Error: Configuration file not found: $configurationFilePath');
      exit(1);
    }
    
    final yamlFileContent = configurationFile.readAsStringSync();
    final parsedYamlData = loadYaml(yamlFileContent) as YamlMap;
    
    // Creating the simulator with our configuration and running it
    final queueingSystemSimulator = Simulator(parsedYamlData, showDetailedOutput: shouldShowVerboseOutput);
    queueingSystemSimulator.run();
    queueingSystemSimulator.printReport();
    
  } catch (error) {
    print('Error: $error');
    exit(1);
  }
}