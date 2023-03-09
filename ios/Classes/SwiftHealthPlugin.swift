import Flutter
import UIKit
import HealthKit

public class SwiftHealthPlugin: NSObject, FlutterPlugin {
    
    let healthStore = HKHealthStore()
    var healthDataTypes = [HKSampleType]()
    var heartRateEventTypes = Set<HKSampleType>()
    var headacheType = Set<HKSampleType>()
    var allDataTypes = Set<HKSampleType>()
    var dataTypesDict: [String: HKSampleType] = [:]
    var unitDict: [String: HKUnit] = [:]
    var workoutActivityTypeMap: [String: HKWorkoutActivityType] = [:]
    
    // Health Data Type Keys
    let ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
    let AUDIOGRAM = "AUDIOGRAM"
    let BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
    let BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
    let BLOOD_OXYGEN = "BLOOD_OXYGEN"
    let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
    let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
    let BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    let BODY_MASS_INDEX = "BODY_MASS_INDEX"
    let BODY_TEMPERATURE = "BODY_TEMPERATURE"
    let DIETARY_CARBS_CONSUMED = "DIETARY_CARBS_CONSUMED"
    let DIETARY_ENERGY_CONSUMED = "DIETARY_ENERGY_CONSUMED"
    let DIETARY_FATS_CONSUMED = "DIETARY_FATS_CONSUMED"
    let DIETARY_PROTEIN_CONSUMED = "DIETARY_PROTEIN_CONSUMED"
    let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
    let FORCED_EXPIRATORY_VOLUME = "FORCED_EXPIRATORY_VOLUME"
    let HEART_RATE = "HEART_RATE"
    let HEART_RATE_VARIABILITY_SDNN = "HEART_RATE_VARIABILITY_SDNN"
    let HEIGHT = "HEIGHT"
    let HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
    let IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"
    let LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
    let RESTING_HEART_RATE = "RESTING_HEART_RATE"
    let STEPS = "STEPS"
    let WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
    let WALKING_HEART_RATE = "WALKING_HEART_RATE"
    let WEIGHT = "WEIGHT"
    let DISTANCE_WALKING_RUNNING = "DISTANCE_WALKING_RUNNING"
    let FLIGHTS_CLIMBED = "FLIGHTS_CLIMBED"
    let WATER = "WATER"
    let MINDFULNESS = "MINDFULNESS"
    let SLEEP_IN_BED = "SLEEP_IN_BED"
    let SLEEP_ASLEEP = "SLEEP_ASLEEP"
    let SLEEP_AWAKE = "SLEEP_AWAKE"
    let EXERCISE_TIME = "EXERCISE_TIME"
    let WORKOUT = "WORKOUT"
    let HEADACHE_UNSPECIFIED = "HEADACHE_UNSPECIFIED"
    let HEADACHE_NOT_PRESENT = "HEADACHE_NOT_PRESENT"
    let HEADACHE_MILD = "HEADACHE_MILD"
    let HEADACHE_MODERATE = "HEADACHE_MODERATE"
    let HEADACHE_SEVERE = "HEADACHE_SEVERE"
    let ELECTROCARDIOGRAM = "ELECTROCARDIOGRAM"
    let ALL_SLEEP = "ALL_SLEEP"
    
    // Health Unit types
    // MOLE_UNIT_WITH_MOLAR_MASS, // requires molar mass input - not supported yet
    // MOLE_UNIT_WITH_PREFIX_MOLAR_MASS, // requires molar mass & prefix input - not supported yet
    let GRAM = "GRAM"
    let KILOGRAM = "KILOGRAM"
    let OUNCE = "OUNCE"
    let POUND = "POUND"
    let STONE = "STONE"
    let METER = "METER"
    let INCH = "INCH"
    let FOOT = "FOOT"
    let YARD = "YARD"
    let MILE = "MILE"
    let LITER = "LITER"
    let MILLILITER = "MILLILITER"
    let FLUID_OUNCE_US = "FLUID_OUNCE_US"
    let FLUID_OUNCE_IMPERIAL = "FLUID_OUNCE_IMPERIAL"
    let CUP_US = "CUP_US"
    let CUP_IMPERIAL = "CUP_IMPERIAL"
    let PINT_US = "PINT_US"
    let PINT_IMPERIAL = "PINT_IMPERIAL"
    let PASCAL = "PASCAL"
    let MILLIMETER_OF_MERCURY = "MILLIMETER_OF_MERCURY"
    let INCHES_OF_MERCURY = "INCHES_OF_MERCURY"
    let CENTIMETER_OF_WATER = "CENTIMETER_OF_WATER"
    let ATMOSPHERE = "ATMOSPHERE"
    let DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL = "DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL"
    let SECOND = "SECOND"
    let MILLISECOND = "MILLISECOND"
    let MINUTE = "MINUTE"
    let HOUR = "HOUR"
    let DAY = "DAY"
    let JOULE = "JOULE"
    let KILOCALORIE = "KILOCALORIE"
    let LARGE_CALORIE = "LARGE_CALORIE"
    let SMALL_CALORIE = "SMALL_CALORIE"
    let DEGREE_CELSIUS = "DEGREE_CELSIUS"
    let DEGREE_FAHRENHEIT = "DEGREE_FAHRENHEIT"
    let KELVIN = "KELVIN"
    let DECIBEL_HEARING_LEVEL = "DECIBEL_HEARING_LEVEL"
    let HERTZ = "HERTZ"
    let SIEMEN = "SIEMEN"
    let VOLT = "VOLT"
    let INTERNATIONAL_UNIT = "INTERNATIONAL_UNIT"
    let COUNT = "COUNT"
    let PERCENT = "PERCENT"
    let BEATS_PER_MINUTE = "BEATS_PER_MINUTE"
    let MILLIGRAM_PER_DECILITER = "MILLIGRAM_PER_DECILITER"
    let UNKNOWN_UNIT = "UNKNOWN_UNIT"
    let NO_UNIT = "NO_UNIT"
    
    struct PluginError: Error {
        let message: String
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_health", binaryMessenger: registrar.messenger())
        let instance = SwiftHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Set up all data types
        initializeTypes()
        
        /// Handle checkIfHealthDataAvailable
        if (call.method.elementsEqual("checkIfHealthDataAvailable")){
            checkIfHealthDataAvailable(call: call, result: result)
        }
        /// Handle requestAuthorization
        else if (call.method.elementsEqual("requestAuthorization")){
            try! requestAuthorization(call: call, result: result)
        }
        
        /// Handle getData
        else if (call.method.elementsEqual("getData")){
            getData(call: call, result: result)
        }
        
        /// Handle getTotalStepsInInterval
        else if (call.method.elementsEqual("getTotalStepsInInterval")){
            getTotalStepsInInterval(call: call, result: result)
        }
        
        /// Handle writeData
        else if (call.method.elementsEqual("writeData")){
            try! writeData(call: call, result: result)
        }
        
        /// Handle writeAudiogram
        else if (call.method.elementsEqual("writeAudiogram")){
            try! writeAudiogram(call: call, result: result)
        }
        
        /// Handle writeWorkoutData
        else if (call.method.elementsEqual("writeWorkoutData")){
            try! writeWorkoutData(call: call, result: result)
        }
        
        /// Handle hasPermission
        else if (call.method.elementsEqual("hasPermissions")){
            try! hasPermissions(call: call, result: result)
        }
    }
    
    func checkIfHealthDataAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(HKHealthStore.isHealthDataAvailable())
    }
    
    func hasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let arguments = call.arguments as? NSDictionary
        guard let types = arguments?["types"] as? Array<String>,
              let permissions = arguments?["permissions"] as? Array<Int>,
              types.count == permissions.count
        else {
            throw PluginError(message: "Invalid Arguments!")
        }
        
        for (index, type) in types.enumerated() {
            let sampleType = dataTypeLookUp(key: type)
            let success = hasPermission(type: sampleType, access: permissions[index])
            if (success == nil || success == false) {
                result(success)
                return
            }
        }
        
        result(true)
    }
    
    
    func hasPermission(type: HKSampleType, access: Int) -> Bool? {
        
        if #available(iOS 13.0, *) {
            let status = healthStore.authorizationStatus(for: type)
            switch access {
            case 0: // READ
                return nil
            case 1: // WRITE
                return  (status == HKAuthorizationStatus.sharingAuthorized)
            default: // READ_WRITE
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func requestAuthorization(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
              let types = arguments["types"] as? Array<String>,
              let permissions = arguments["permissions"] as? Array<Int>,
              permissions.count == types.count
        else {
            throw PluginError(message: "Invalid Arguments!")
        }
        
        
        var typesToRead = Set<HKSampleType>()
        var typesToWrite = Set<HKSampleType>()
        for (index, key) in types.enumerated() {
            let dataType = dataTypeLookUp(key: key)
            let access = permissions[index]
            switch access {
            case 0:
                typesToRead.insert(dataType)
            case 1:
                typesToWrite.insert(dataType)
            default:
                typesToRead.insert(dataType)
                typesToWrite.insert(dataType)
            }
        }
        
        if #available(iOS 13.0, *) {
            healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
                DispatchQueue.main.async {
                    result(success)
                }
            }
        }
        else {
            result(false)// Handle the error here.
        }
    }
    
    func writeData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
              let value = (arguments["value"] as? Double),
              let type = (arguments["dataTypeKey"] as? String),
              let unit = (arguments["dataUnitKey"] as? String),
              let startTime = (arguments["startTime"] as? NSNumber),
              let endTime = (arguments["endTime"] as? NSNumber)
        else {
            throw PluginError(message: "Invalid Arguments")
        }
        
        let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        
        let sample: HKObject
        
        if (unitLookUp(key: type) == HKUnit.init(from: "")) {
            sample = HKCategorySample(type: dataTypeLookUp(key: type) as! HKCategoryType, value: Int(value), start: dateFrom, end: dateTo)
        } else {
            let quantity = HKQuantity(unit: unitDict[unit]!, doubleValue: value)
            
            sample = HKQuantitySample(type: dataTypeLookUp(key: type) as! HKQuantityType, quantity: quantity, start: dateFrom, end: dateTo)
        }
        
        HKHealthStore().save(sample, withCompletion: { (success, error) in
            if let err = error {
                print("Error Saving \(type) Sample: \(err.localizedDescription)")
            }
            DispatchQueue.main.async {
                result(success)
            }
        })
    }
    
    func writeAudiogram(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
              let frequencies = (arguments["frequencies"] as? Array<Double>),
              let leftEarSensitivities = (arguments["leftEarSensitivities"] as? Array<Double>),
              let rightEarSensitivities = (arguments["rightEarSensitivities"] as? Array<Double>),
              let startTime = (arguments["startTime"] as? NSNumber),
              let endTime = (arguments["endTime"] as? NSNumber)
        else {
            
            throw PluginError(message: "Invalid Arguments")
        }
        
        let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        
        var sensitivityPoints = [HKAudiogramSensitivityPoint]()
        
        for index in 0...frequencies.count-1 {
            let frequency = HKQuantity(unit: HKUnit.hertz(), doubleValue: frequencies[index])
            let dbUnit = HKUnit.decibelHearingLevel()
            let left = HKQuantity(unit: dbUnit, doubleValue: leftEarSensitivities[index])
            let right = HKQuantity(unit: dbUnit, doubleValue: rightEarSensitivities[index])
            let sensitivityPoint = try HKAudiogramSensitivityPoint(frequency: frequency,  leftEarSensitivity: left, rightEarSensitivity: right)
            sensitivityPoints.append(sensitivityPoint)
        }
        
        let audiogram: HKAudiogramSample;
        let metadataReceived = (arguments["metadata"] as? [String: Any]?)
        
        if((metadataReceived) != nil) {
            guard let deviceName = metadataReceived?!["HKDeviceName"] as? String else { return }
            guard let externalUUID = metadataReceived?!["HKExternalUUID"] as? String else { return }
            
            audiogram = HKAudiogramSample(sensitivityPoints:sensitivityPoints, start: dateFrom, end: dateTo, metadata: [HKMetadataKeyDeviceName: deviceName, HKMetadataKeyExternalUUID: externalUUID])
            
        } else {
            audiogram = HKAudiogramSample(sensitivityPoints:sensitivityPoints, start: dateFrom, end: dateTo, metadata: nil)
        }
        
        HKHealthStore().save(audiogram, withCompletion: { (success, error) in
            if let err = error {
                print("Error Saving Audiogram. Sample: \(err.localizedDescription)")
            }
            DispatchQueue.main.async {
                result(success)
            }
        })
    }
    
    func writeWorkoutData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments = call.arguments as? NSDictionary,
              let activityType = (arguments["activityType"] as? String),
              let startTime = (arguments["startTime"] as? NSNumber),
              let endTime = (arguments["endTime"] as? NSNumber),
              let ac = workoutActivityTypeMap[activityType]
        else {
            throw PluginError(message: "Invalid Arguments - ActivityType, startTime or endTime invalid")
        }
        
        var totalEnergyBurned: HKQuantity?
        var totalDistance: HKQuantity? = nil
        
        // Handle optional arguments
        if let teb = (arguments["totalEnergyBurned"] as? Double) {
            totalEnergyBurned = HKQuantity(unit: unitDict[(arguments["totalEnergyBurnedUnit"] as! String)]!, doubleValue: teb)
        }
        if let td = (arguments["totalDistance"] as? Double) {
            totalDistance = HKQuantity(unit: unitDict[(arguments["totalDistanceUnit"] as! String)]!, doubleValue: td)
        }
        
       let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
       let dateTo = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        
        var workout: HKWorkout
        
        workout = HKWorkout(activityType: ac, start: dateFrom, end: dateTo, duration: dateTo.timeIntervalSince(dateFrom),
                            totalEnergyBurned: totalEnergyBurned ?? nil,
                            totalDistance: totalDistance ?? nil, metadata: nil)
        
        HKHealthStore().save(workout, withCompletion: { (success, error) in
            if let err = error {
                print("Error Saving Workout. Sample: \(err.localizedDescription)")
            }
            DispatchQueue.main.async {
                result(success)
            }
        })
    }
    
    func getData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String)!
        let dataUnitKey = (arguments?["dataUnitKey"] as? String)
        let startTime = (arguments?["startTime"] as? NSNumber) ?? 0
        let endTime = (arguments?["endTime"] as? NSNumber) ?? 0
        let limit = (arguments?["limit"] as? Int) ?? HKObjectQueryNoLimit
        
        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        
        let dataType = dataTypeLookUp(key: dataTypeKey)
        var unit: HKUnit?
        if let dataUnitKey = dataUnitKey {
            unit = unitDict[dataUnitKey]
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        
        let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { [self]
            x, samplesOrNil, error in
            
            switch samplesOrNil {
            case let (samples as [HKQuantitySample]) as Any:
                let dictionaries = samples.map { sample -> NSDictionary in
                    
                    return [
                        "uuid": "\(sample.uuid)",
                        "value": sample.quantity.doubleValue(for: unit!),
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name,
                        "device": [
                             "udi_device_identifier": sample.device?.udiDeviceIdentifier,
                             "firmware_version": sample.device?.firmwareVersion,
                             "hardware_version": sample.device?.hardwareVersion,
                             "manufacturer": sample.device?.manufacturer,
                             "model": sample.device?.model,
                             "name": sample.device?.name,
                             "software_version": sample.device?.softwareVersion
                        ]
                    ]
                }
                DispatchQueue.main.async {
                    result(dictionaries)
                }
                
            case var (samplesCategory as [HKCategorySample]) as Any:
                                
                if (dataTypeKey == self.ALL_SLEEP) {
                    var uuid = ""
                    var date_from = 0
                    var date_to = 0
                    var source_id = ""
                    var source_name = ""
                    var udi_device_identifier = ""
                    var firmware_version = ""
                    var hardware_version = ""
                    var manufacturer = ""
                    var model = ""
                    var name = ""
                    var software_version = ""
                    
                    
                    var originSleepList : [OriginSleep] = [OriginSleep]()
                    if #available(iOS 16.0, *) {
                                                
                        let sleepData = samplesCategory.reversed()
                        
                        for element in sleepData {
                            let originSleep: OriginSleep = OriginSleep()

                            let sleepDown = Int(element.startDate.timeIntervalSince1970)
                            let sleepUp = Int(element.endDate.timeIntervalSince1970)

                            originSleep.sleepDown = sleepDown
                            originSleep.sleepUp = sleepUp
                            
                            print("type: \(element.value) sleepDown: \(sleepDown) - sleepUp: \(sleepUp)")
                            if element.value == HKCategoryValueSleepAnalysis.awake.rawValue {
                                originSleep.type = 2
                            } else if element.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue {
                                originSleep.type = 3
                            } else if element.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue {
                                originSleep.type = 4
                            } else if element.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                                originSleep.type = 5
                            } else {
                                continue
                            }
                            originSleepList.append(originSleep)
                        }
                    }

                    if samplesCategory.count > 0 {
                        let sample = samplesCategory.first
                        uuid = "\(String(describing: sample?.uuid))"
                        date_from = Int((sample?.startDate.timeIntervalSince1970 ?? 0) * 1000)
                        date_to = Int((sample?.endDate.timeIntervalSince1970 ?? 0) * 1000)
                        source_id = sample?.sourceRevision.source.bundleIdentifier ?? ""
                        source_name = sample?.sourceRevision.source.name ?? ""
                        udi_device_identifier = sample?.device?.udiDeviceIdentifier ?? ""
                        firmware_version = sample?.device?.firmwareVersion ?? ""
                        hardware_version = sample?.device?.hardwareVersion ?? ""
                        manufacturer = sample?.device?.manufacturer ?? ""
                        model = sample?.device?.model ?? ""
                        name = sample?.device?.name ?? ""
                        software_version = sample?.device?.softwareVersion ?? ""
                    }
                    
                    let sleepDataList = SleepData.getSleep(originSleepList: originSleepList)
                    
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try! jsonEncoder.encode(sleepDataList)
                    let sleepJson = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
                    
                    
                    print("sleepJson: \(sleepJson)")
                    
                    let record = [
                        "uuid": uuid,
                        "value": sleepJson,
                        "date_from": date_from,
                        "date_to": date_to,
                        "source_id": source_id,
                        "source_name": source_name,
                        "device": [
                            "udi_device_identifier": udi_device_identifier,
                            "firmware_version": firmware_version,
                            "hardware_version": hardware_version,
                            "manufacturer": manufacturer,
                            "model": model,
                            "name": name,
                            "software_version": software_version,
                        ]
                    ]
                
                        
                    
                    DispatchQueue.main.async {
                        result([record])
                    }
                } else {
                    
                    if (dataTypeKey == self.SLEEP_IN_BED) {
                        samplesCategory = samplesCategory.filter { $0.value == 0 }
                    }
                    if (dataTypeKey == self.SLEEP_ASLEEP) {
                        samplesCategory = samplesCategory.filter { $0.value == 1 }
                    }
                    if (dataTypeKey == self.SLEEP_AWAKE) {
                        samplesCategory = samplesCategory.filter { $0.value == 2 }
                    }
                    if (dataTypeKey == self.HEADACHE_UNSPECIFIED) {
                        samplesCategory = samplesCategory.filter { $0.value == 0 }
                    }
                    if (dataTypeKey == self.HEADACHE_NOT_PRESENT) {
                        samplesCategory = samplesCategory.filter { $0.value == 1 }
                    }
                    if (dataTypeKey == self.HEADACHE_MILD) {
                        samplesCategory = samplesCategory.filter { $0.value == 2 }
                    }
                    if (dataTypeKey == self.HEADACHE_MODERATE) {
                        samplesCategory = samplesCategory.filter { $0.value == 3 }
                    }
                    if (dataTypeKey == self.HEADACHE_SEVERE) {
                        samplesCategory = samplesCategory.filter { $0.value == 4 }
                    }
                    let categories = samplesCategory.map { sample -> NSDictionary in
                        return [
                            "uuid": "\(sample.uuid)",
                            "value": sample.value,
                            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                            "source_id": sample.sourceRevision.source.bundleIdentifier,
                            "source_name": sample.sourceRevision.source.name,
                            "device": [
                                "udi_device_identifier": sample.device?.udiDeviceIdentifier,
                                "firmware_version": sample.device?.firmwareVersion,
                                "hardware_version": sample.device?.hardwareVersion,
                                "manufacturer": sample.device?.manufacturer,
                                "model": sample.device?.model,
                                "name": sample.device?.name,
                                "software_version": sample.device?.softwareVersion
                            ]
                        ]
                    }
                    DispatchQueue.main.async {
                        result(categories)
                    }
                }
                
            case let (samplesWorkout as [HKWorkout]) as Any:
                
                let dictionaries = samplesWorkout.map { sample -> NSDictionary in
                
                    return [
                        "uuid": "\(sample.uuid)",
                        "workoutActivityType": workoutActivityTypeMap.first(where: {$0.value == sample.workoutActivityType})?.key,
                        "totalEnergyBurned": sample.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()),
                        "totalEnergyBurnedUnit": "KILOCALORIE",
                        "totalDistance": sample.totalDistance?.doubleValue(for: HKUnit.meter()),
                        "totalDistanceUnit": "METER",
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name,
                        "device": [
                             "udi_device_identifier": sample.device?.udiDeviceIdentifier,
                             "firmware_version": sample.device?.firmwareVersion,
                             "hardware_version": sample.device?.hardwareVersion,
                             "manufacturer": sample.device?.manufacturer,
                             "model": sample.device?.model,
                             "name": sample.device?.name,
                             "software_version": sample.device?.softwareVersion
                        ]
                    ]
                }
                
                DispatchQueue.main.async {
                    result(dictionaries)
                }
                
            case let (samplesAudiogram as [HKAudiogramSample]) as Any:
                let dictionaries = samplesAudiogram.map { sample -> NSDictionary in
                    var frequencies = [Double]()
                    var leftEarSensitivities = [Double]()
                    var rightEarSensitivities = [Double]()
                    for samplePoint in sample.sensitivityPoints {
                        frequencies.append(samplePoint.frequency.doubleValue(for: HKUnit.hertz()))
                        leftEarSensitivities.append(samplePoint.leftEarSensitivity!.doubleValue(for: HKUnit.decibelHearingLevel()))
                        rightEarSensitivities.append(samplePoint.rightEarSensitivity!.doubleValue(for: HKUnit.decibelHearingLevel()))
                    }
                    
                    return [
                        "uuid": "\(sample.uuid)",
                        "frequencies": frequencies,
                        "leftEarSensitivities": leftEarSensitivities,
                        "rightEarSensitivities": rightEarSensitivities,
                        "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                        "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                        "source_id": sample.sourceRevision.source.bundleIdentifier,
                        "source_name": sample.sourceRevision.source.name,
                        "device": [
                             "udi_device_identifier": sample.device?.udiDeviceIdentifier,
                             "firmware_version": sample.device?.firmwareVersion,
                             "hardware_version": sample.device?.hardwareVersion,
                             "manufacturer": sample.device?.manufacturer,
                             "model": sample.device?.model,
                             "name": sample.device?.name,
                             "software_version": sample.device?.softwareVersion
                        ]
                    ]
                }
                DispatchQueue.main.async {
                    result(dictionaries)
                }
                
            default:
                if #available(iOS 14.0, *), let ecgSamples = samplesOrNil as? [HKElectrocardiogram] {
                    let dictionaries = ecgSamples.map(fetchEcgMeasurements)
                    DispatchQueue.main.async {
                        result(dictionaries)
                    }
                } else {
                    DispatchQueue.main.async {
                        result(nil)
                    }
                }
            }
        }
        
        HKHealthStore().execute(query)
    }
    
    @available(iOS 14.0, *)
    private func fetchEcgMeasurements(_ sample: HKElectrocardiogram) -> NSDictionary {
        let semaphore = DispatchSemaphore(value: 0)
        var voltageValues = [NSDictionary]()
        let voltageQuery = HKElectrocardiogramQuery(sample) { query, result in
            switch (result) {
            case let .measurement(measurement):
                if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                    let voltage = voltageQuantity.doubleValue(for: HKUnit.volt())
                    let timeSinceSampleStart = measurement.timeSinceSampleStart
                    voltageValues.append(["voltage": voltage, "timeSinceSampleStart": timeSinceSampleStart])
                }
            case .done:
                semaphore.signal()
            case let .error(error):
                print(error)
            }
        }
        HKHealthStore().execute(voltageQuery)
        semaphore.wait()
        return [
            "uuid": "\(sample.uuid)",
            "voltageValues": voltageValues,
            "averageHeartRate": sample.averageHeartRate?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())),
            "samplingFrequency": sample.samplingFrequency?.doubleValue(for: HKUnit.hertz()),
            "classification": sample.classification.rawValue,
            "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
            "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
            "source_id": sample.sourceRevision.source.bundleIdentifier,
            "source_name": sample.sourceRevision.source.name,
            "device": [
                 "udi_device_identifier": sample.device?.udiDeviceIdentifier,
                 "firmware_version": sample.device?.firmwareVersion,
                 "hardware_version": sample.device?.hardwareVersion,
                 "manufacturer": sample.device?.manufacturer,
                 "model": sample.device?.model,
                 "name": sample.device?.name,
                 "software_version": sample.device?.softwareVersion
            ]
        ]
    }
    
    func getTotalStepsInInterval(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let startTime = (arguments?["startTime"] as? NSNumber) ?? 0
        let endTime = (arguments?["endTime"] as? NSNumber) ?? 0
        
        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startTime.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endTime.doubleValue / 1000)
        
        let sampleType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: sampleType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { query, queryResult, error in
            
            guard let queryResult = queryResult else {
                let error = error! as NSError
                print("Error getting total steps in interval \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            var steps = 0.0
            
            if let quantity = queryResult.sumQuantity() {
                let unit = HKUnit.count()
                steps = quantity.doubleValue(for: unit)
            }
            
            let totalSteps = Int(steps)
            DispatchQueue.main.async {
                result(totalSteps)
            }
        }
        
        HKHealthStore().execute(query)
    }
    
    func unitLookUp(key: String) -> HKUnit {
        guard let unit = unitDict[key] else {
            return HKUnit.count()
        }
        return unit
    }
    
    func dataTypeLookUp(key: String) -> HKSampleType {
        guard let dataType_ = dataTypesDict[key] else {
            return HKSampleType.quantityType(forIdentifier: .bodyMass)!
        }
        return dataType_
    }
    
    func initializeTypes() {
        // Initialize units
        unitDict[GRAM] = HKUnit.gram()
        unitDict[KILOGRAM] = HKUnit.gramUnit(with: .kilo)
        unitDict[OUNCE] = HKUnit.ounce()
        unitDict[POUND] = HKUnit.pound()
        unitDict[STONE] = HKUnit.stone()
        unitDict[METER] = HKUnit.meter()
        unitDict[INCH] = HKUnit.inch()
        unitDict[FOOT] = HKUnit.foot()
        unitDict[YARD] = HKUnit.yard()
        unitDict[MILE] = HKUnit.mile()
        unitDict[LITER] = HKUnit.liter()
        unitDict[MILLILITER] = HKUnit.literUnit(with: .milli)
        unitDict[FLUID_OUNCE_US] = HKUnit.fluidOunceUS()
        unitDict[FLUID_OUNCE_IMPERIAL] = HKUnit.fluidOunceImperial()
        unitDict[CUP_US] = HKUnit.cupUS()
        unitDict[CUP_IMPERIAL] = HKUnit.cupImperial()
        unitDict[PINT_US] = HKUnit.pintUS()
        unitDict[PINT_IMPERIAL] = HKUnit.pintImperial()
        unitDict[PASCAL] = HKUnit.pascal()
        unitDict[MILLIMETER_OF_MERCURY] = HKUnit.millimeterOfMercury()
        unitDict[CENTIMETER_OF_WATER] = HKUnit.centimeterOfWater()
        unitDict[ATMOSPHERE] = HKUnit.atmosphere()
        unitDict[DECIBEL_A_WEIGHTED_SOUND_PRESSURE_LEVEL] = HKUnit.decibelAWeightedSoundPressureLevel()
        unitDict[SECOND] = HKUnit.second()
        unitDict[MILLISECOND] = HKUnit.secondUnit(with: .milli)
        unitDict[MINUTE] = HKUnit.minute()
        unitDict[HOUR] = HKUnit.hour()
        unitDict[DAY] = HKUnit.day()
        unitDict[JOULE] = HKUnit.joule()
        unitDict[KILOCALORIE] = HKUnit.kilocalorie()
        unitDict[LARGE_CALORIE] = HKUnit.largeCalorie()
        unitDict[SMALL_CALORIE] = HKUnit.smallCalorie()
        unitDict[DEGREE_CELSIUS] = HKUnit.degreeCelsius()
        unitDict[DEGREE_FAHRENHEIT] = HKUnit.degreeFahrenheit()
        unitDict[KELVIN] = HKUnit.kelvin()
        unitDict[DECIBEL_HEARING_LEVEL] = HKUnit.decibelHearingLevel()
        unitDict[HERTZ] = HKUnit.hertz()
        unitDict[SIEMEN] = HKUnit.siemen()
        unitDict[INTERNATIONAL_UNIT] = HKUnit.internationalUnit()
        unitDict[COUNT] = HKUnit.count()
        unitDict[PERCENT] = HKUnit.percent()
        unitDict[BEATS_PER_MINUTE] = HKUnit.init(from: "count/min")
        unitDict[MILLIGRAM_PER_DECILITER] = HKUnit.init(from: "mg/dL")
        unitDict[UNKNOWN_UNIT] = HKUnit.init(from: "")
        unitDict[NO_UNIT] = HKUnit.init(from: "")
        
        // Initialize workout types
        workoutActivityTypeMap["ARCHERY"] = .archery
        workoutActivityTypeMap["BOWLING"] = .bowling
        workoutActivityTypeMap["FENCING"] = .fencing
        workoutActivityTypeMap["GYMNASTICS"] = .gymnastics
        workoutActivityTypeMap["TRACK_AND_FIELD"] = .trackAndField
        workoutActivityTypeMap["AMERICAN_FOOTBALL"] = .americanFootball
        workoutActivityTypeMap["AUSTRALIAN_FOOTBALL"] = .australianFootball
        workoutActivityTypeMap["BASEBALL"] = .baseball
        workoutActivityTypeMap["BASKETBALL"] = .basketball
        workoutActivityTypeMap["CRICKET"] = .cricket
        workoutActivityTypeMap["DISC_SPORTS"] = .discSports
        workoutActivityTypeMap["HANDBALL"] = .handball
        workoutActivityTypeMap["HOCKEY"] = .hockey
        workoutActivityTypeMap["LACROSSE"] = .lacrosse
        workoutActivityTypeMap["RUGBY"] = .rugby
        workoutActivityTypeMap["SOCCER"] = .soccer
        workoutActivityTypeMap["SOFTBALL"] = .softball
        workoutActivityTypeMap["VOLLEYBALL"] = .volleyball
        workoutActivityTypeMap["PREPARATION_AND_RECOVERY"] = .preparationAndRecovery
        workoutActivityTypeMap["FLEXIBILITY"] = .flexibility
        workoutActivityTypeMap["WALKING"] = .walking
        workoutActivityTypeMap["RUNNING"] = .running
        workoutActivityTypeMap["RUNNING_JOGGING"] = .running // Supported due to combining with Android naming
        workoutActivityTypeMap["RUNNING_SAND"] = .running // Supported due to combining with Android naming
        workoutActivityTypeMap["RUNNING_TREADMILL"] = .running // Supported due to combining with Android naming
        workoutActivityTypeMap["WHEELCHAIR_WALK_PACE"] = .wheelchairWalkPace
        workoutActivityTypeMap["WHEELCHAIR_RUN_PACE"] = .wheelchairRunPace
        workoutActivityTypeMap["BIKING"] = .cycling
        workoutActivityTypeMap["HAND_CYCLING"] = .handCycling
        workoutActivityTypeMap["CORE_TRAINING"] = .coreTraining
        workoutActivityTypeMap["ELLIPTICAL"] = .elliptical
        workoutActivityTypeMap["FUNCTIONAL_STRENGTH_TRAINING"] = .functionalStrengthTraining
        workoutActivityTypeMap["TRADITIONAL_STRENGTH_TRAINING"] = .traditionalStrengthTraining
        workoutActivityTypeMap["CROSS_TRAINING"] = .crossTraining
        workoutActivityTypeMap["MIXED_CARDIO"] = .mixedCardio
        workoutActivityTypeMap["HIGH_INTENSITY_INTERVAL_TRAINING"] = .highIntensityIntervalTraining
        workoutActivityTypeMap["JUMP_ROPE"] = .jumpRope
        workoutActivityTypeMap["STAIR_CLIMBING"] = .stairClimbing
        workoutActivityTypeMap["STAIRS"] = .stairs
        workoutActivityTypeMap["STEP_TRAINING"] = .stepTraining
        workoutActivityTypeMap["FITNESS_GAMING"] = .fitnessGaming
        workoutActivityTypeMap["BARRE"] = .barre
        workoutActivityTypeMap["YOGA"] = .yoga
        workoutActivityTypeMap["MIND_AND_BODY"] = .mindAndBody
        workoutActivityTypeMap["PILATES"] = .pilates
        workoutActivityTypeMap["BADMINTON"] = .badminton
        workoutActivityTypeMap["RACQUETBALL"] = .racquetball
        workoutActivityTypeMap["SQUASH"] = .squash
        workoutActivityTypeMap["TABLE_TENNIS"] = .tableTennis
        workoutActivityTypeMap["TENNIS"] = .tennis
        workoutActivityTypeMap["CLIMBING"] = .climbing
        workoutActivityTypeMap["ROCK_CLIMBING"] = .climbing // Supported due to combining with Android naming
        workoutActivityTypeMap["EQUESTRIAN_SPORTS"] = .equestrianSports
        workoutActivityTypeMap["FISHING"] = .fishing
        workoutActivityTypeMap["GOLF"] = .golf
        workoutActivityTypeMap["HIKING"] = .hiking
        workoutActivityTypeMap["HUNTING"] = .hunting
        workoutActivityTypeMap["PLAY"] = .play
        workoutActivityTypeMap["CROSS_COUNTRY_SKIING"] = .crossCountrySkiing
        workoutActivityTypeMap["CURLING"] = .curling
        workoutActivityTypeMap["DOWNHILL_SKIING"] = .downhillSkiing
        workoutActivityTypeMap["SNOW_SPORTS"] = .snowSports
        workoutActivityTypeMap["SNOWBOARDING"] = .snowboarding
        workoutActivityTypeMap["SKATING"] = .skatingSports
        workoutActivityTypeMap["SKATING_CROSS,"] = .skatingSports // Supported due to combining with Android naming
        workoutActivityTypeMap["SKATING_INDOOR,"] = .skatingSports // Supported due to combining with Android naming
        workoutActivityTypeMap["SKATING_INLINE,"] = .skatingSports // Supported due to combining with Android naming
        workoutActivityTypeMap["PADDLE_SPORTS"] = .paddleSports
        workoutActivityTypeMap["ROWING"] = .rowing
        workoutActivityTypeMap["SAILING"] = .sailing
        workoutActivityTypeMap["SURFING_SPORTS"] = .surfingSports
        workoutActivityTypeMap["SWIMMING"] = .swimming
        workoutActivityTypeMap["WATER_FITNESS"] = .waterFitness
        workoutActivityTypeMap["WATER_POLO"] = .waterPolo
        workoutActivityTypeMap["WATER_SPORTS"] = .waterSports
        workoutActivityTypeMap["BOXING"] = .boxing
        workoutActivityTypeMap["KICKBOXING"] = .kickboxing
        workoutActivityTypeMap["MARTIAL_ARTS"] = .martialArts
        workoutActivityTypeMap["TAI_CHI"] = .taiChi
        workoutActivityTypeMap["WRESTLING"] = .wrestling
        workoutActivityTypeMap["OTHER"] = .other
        
        
        
        // Set up iOS 13 specific types (ordinary health data types)
        if #available(iOS 13.0, *) {
            dataTypesDict[ACTIVE_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
            dataTypesDict[AUDIOGRAM] = HKSampleType.audiogramSampleType()
            dataTypesDict[BASAL_ENERGY_BURNED] = HKSampleType.quantityType(forIdentifier: .basalEnergyBurned)!
            dataTypesDict[BLOOD_GLUCOSE] = HKSampleType.quantityType(forIdentifier: .bloodGlucose)!
            dataTypesDict[BLOOD_OXYGEN] = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)!
            dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!
            dataTypesDict[BODY_FAT_PERCENTAGE] = HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!
            dataTypesDict[BODY_MASS_INDEX] = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
            dataTypesDict[BODY_TEMPERATURE] = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
            dataTypesDict[DIETARY_CARBS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryCarbohydrates)!
            dataTypesDict[DIETARY_ENERGY_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            dataTypesDict[DIETARY_FATS_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryFatTotal)!
            dataTypesDict[DIETARY_PROTEIN_CONSUMED] = HKSampleType.quantityType(forIdentifier: .dietaryProtein)!
            dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKSampleType.quantityType(forIdentifier: .electrodermalActivity)!
            dataTypesDict[FORCED_EXPIRATORY_VOLUME] = HKSampleType.quantityType(forIdentifier: .forcedExpiratoryVolume1)!
            dataTypesDict[HEART_RATE] = HKSampleType.quantityType(forIdentifier: .heartRate)!
            dataTypesDict[HEART_RATE_VARIABILITY_SDNN] = HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
            dataTypesDict[HEIGHT] = HKSampleType.quantityType(forIdentifier: .height)!
            dataTypesDict[RESTING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .restingHeartRate)!
            dataTypesDict[STEPS] = HKSampleType.quantityType(forIdentifier: .stepCount)!
            dataTypesDict[WAIST_CIRCUMFERENCE] = HKSampleType.quantityType(forIdentifier: .waistCircumference)!
            dataTypesDict[WALKING_HEART_RATE] = HKSampleType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            dataTypesDict[WEIGHT] = HKSampleType.quantityType(forIdentifier: .bodyMass)!
            dataTypesDict[DISTANCE_WALKING_RUNNING] = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
            dataTypesDict[FLIGHTS_CLIMBED] = HKSampleType.quantityType(forIdentifier: .flightsClimbed)!
            dataTypesDict[WATER] = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
            dataTypesDict[MINDFULNESS] = HKSampleType.categoryType(forIdentifier: .mindfulSession)!
            dataTypesDict[SLEEP_IN_BED] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_ASLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[SLEEP_AWAKE] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
            dataTypesDict[EXERCISE_TIME] = HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
            dataTypesDict[WORKOUT] = HKSampleType.workoutType()
            
            healthDataTypes = Array(dataTypesDict.values)
        }
        // Set up heart rate data types specific to the apple watch, requires iOS 12
        if #available(iOS 12.2, *){
            dataTypesDict[HIGH_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!
            dataTypesDict[LOW_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!
            dataTypesDict[IRREGULAR_HEART_RATE_EVENT] = HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!
            
            heartRateEventTypes =  Set([
                HKSampleType.categoryType(forIdentifier: .highHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .lowHeartRateEvent)!,
                HKSampleType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
            ])
        }
        
        if #available(iOS 13.6, *){
            dataTypesDict[HEADACHE_UNSPECIFIED] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_NOT_PRESENT] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_MILD] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_MODERATE] = HKSampleType.categoryType(forIdentifier: .headache)!
            dataTypesDict[HEADACHE_SEVERE] = HKSampleType.categoryType(forIdentifier: .headache)!
            
            headacheType = Set([
                HKSampleType.categoryType(forIdentifier: .headache)!,
            ])
        }
        
        if #available(iOS 14.0, *) {
            dataTypesDict[ELECTROCARDIOGRAM] = HKSampleType.electrocardiogramType()
            
            unitDict[VOLT] = HKUnit.volt()
            unitDict[INCHES_OF_MERCURY] = HKUnit.inchesOfMercury()
            
            workoutActivityTypeMap["CARDIO_DANCE"] = HKWorkoutActivityType.cardioDance
            workoutActivityTypeMap["SOCIAL_DANCE"] = HKWorkoutActivityType.socialDance
            workoutActivityTypeMap["PICKLEBALL"] = HKWorkoutActivityType.pickleball
            workoutActivityTypeMap["COOLDOWN"] = HKWorkoutActivityType.cooldown
        }
        

        if #available(iOS 16.0, *) {
            dataTypesDict[ALL_SLEEP] = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!
        }
        

        
        // Concatenate heart events, headache and health data types (both may be empty)
        allDataTypes = Set(heartRateEventTypes + healthDataTypes)
        allDataTypes = allDataTypes.union(headacheType)
    }
}


public class SleepData: Codable {
    public var date: String = ""
    
    public var sleepLine: String = ""
    public var sleepDown: String = ""
    public var sleepUp: String = ""
    public var accurateType: Int = 1
    
    public var sleepQuality: Int = 0
   
    static func getSleep(originSleepList: [OriginSleep]) -> SleepData {
        let sleepData = SleepData()
        sleepData.sleepDown = getSleepDown(originSleepList: originSleepList)
        sleepData.sleepUp = getSleepUp(originSleepList: originSleepList)
        print("sleepData.sleepDown: \(sleepData.sleepDown) sleepData.sleepUp: \(sleepData.sleepUp)")
        sleepData.sleepLine = getSleepLine(originSleepList: originSleepList)
        sleepData.accurateType = 1
        return sleepData
    }
    
    // Sleep up value will round up
    static func getSleepUp(originSleepList: [OriginSleep]) -> String {
        var sleepUp =  "2000-01-01 00:00:00"
        if (originSleepList.isEmpty){
            return sleepUp
        }
        let lastSleep = originSleepList.last
        let valueAfterRound = Util.roundUpTimestampPrecision(lastSleep!.sleepUp)
        sleepUp = Date(timeIntervalSince1970: TimeInterval(valueAfterRound)).convertDateToString()
        return sleepUp
    }
    
    // Sleep down value will round down
    static func getSleepDown(originSleepList: [OriginSleep]) -> String {
        var sleepDown = "2000-01-01 00:00:00"
        if (originSleepList.isEmpty){
            return sleepDown
        }
        let firstSleep = originSleepList.first
        let valueAfterRound = Util.roundDownTimestampPrecision(firstSleep!.sleepDown)
        sleepDown = Date(timeIntervalSince1970: TimeInterval(valueAfterRound)).convertDateToString()
        return sleepDown
    }
    
    static func getSleepLine(originSleepList: [OriginSleep]) -> String {
        var sleepLine: String = ""
        var lastSleepLineValue = ""
        if (originSleepList.isEmpty){
            return sleepLine
        }
        
        originSleepList.first!.sleepDown = Util.roundDownTimestampPrecision(originSleepList.first!.sleepDown)
        originSleepList.last!.sleepUp = Util.roundUpTimestampPrecision(originSleepList.last!.sleepUp)
        
        for (index, element) in originSleepList.enumerated() {
            print("type: \(element.type) element.sleepDown: \(Date(timeIntervalSince1970: TimeInterval(element.sleepDown)).convertDateToString()) - element.sleepUp: \(Date(timeIntervalSince1970: TimeInterval(element.sleepUp)).convertDateToString())")
            let sleepUpAfterRoundUp = Util.roundUpTimestampPrecisionTo30Seconds(element.sleepUp)
            let sleepDownAfterRoundUp = Util.roundUpTimestampPrecisionTo30Seconds(element.sleepDown)
            
            let sleepLength = (sleepUpAfterRoundUp - sleepDownAfterRoundUp) / 60
            print("sleepLength: \(sleepLength)")
            var line : String = ""
            
            /// Convert from type in Apple Watch to type in our app.
            /// Apple Watch Type:
            ///  awake: 2 - core: 3 - deep: 4 - rem: 5
            ///
            ///  Our app:
            ///  awake: 4 - core (Light): 1 - deep: 0 - rem: 2
            ///
            if element.type == 0 {
                continue
            }
            
            print("sleepUpAfterRoundUp: \(sleepUpAfterRoundUp) - sleepDownAfterRoundUp \(sleepDownAfterRoundUp)")
            print("element.sleepUp: \(element.sleepUp) - element.sleepDown: \( element.sleepDown)")
                
            // Only add the value if minute cycle = 30s and it is between 2 cycles the same type
            if ((sleepUpAfterRoundUp - sleepDownAfterRoundUp) == 60) && (element.sleepUp - element.sleepDown) == 30 {
                
                if (index + 1 > originSleepList.count) {
                    let previousElement = originSleepList[index - 1]
                    let nextElement = originSleepList[index + 1]
                    
                    if (previousElement.type == nextElement.type) {
                        line = lastSleepLineValue
                        print("add value with type \(element.type) ")
                        sleepLine.append(line)
                        continue
                    }
                }
            
            }
            
            if element.type == 2 {
                line = String(repeating: "4", count: sleepLength)
                lastSleepLineValue = "4"
            }else if element.type == 3 {
                line = String(repeating: "1", count: sleepLength)
                lastSleepLineValue = "1"
            } else if element.type == 4 {
                line = String(repeating: "0", count: sleepLength)
                lastSleepLineValue = "0"
            } else if element.type == 5 {
                line = String(repeating: "2", count: sleepLength)
                lastSleepLineValue = "2"
            }
            sleepLine.append(line)
        }

        print("sleepLine: \(sleepLine) - length: \(sleepLine.count)")
        return sleepLine.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


public class OriginSleep: Codable {
    // type: 2: awake - 3: core: (Light) - 4: deep - 5: REM
    public var type: Int = 0
    public var sleepDown: Int = 0
    public var sleepUp: Int = 0
    
}

public class Util {
    static func roundUpTimestampPrecisionTo30Seconds(_ timstamp: Int) -> Int {
        let seconds = timstamp % 60
        let roundedTimeInterval = timstamp - seconds
        if seconds >= 30 {
            return roundedTimeInterval + 60
        } else {
            return roundedTimeInterval
        }
    }

    static func roundUpTimestampPrecision(_ timstamp: Int) -> Int {
        let seconds = timstamp % 60
        let roundedTimeInterval = timstamp - seconds
        return roundedTimeInterval + 60
    }
    
    static func roundDownTimestampPrecision(_ timstamp: Int) -> Int {
        let seconds = timstamp % 60
        let roundedTimeInterval = timstamp - seconds
        return roundedTimeInterval
    }
}



extension Date {
    func convertDateToString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: self)
    }
}
