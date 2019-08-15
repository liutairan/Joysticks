//
//  ViewController.swift
//  Joysticks
//
//  Created by TAIRAN LIU on 1/9/17.
//  Copyright © 2017 TAIRAN LIU. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextFieldDelegate, StreamDelegate {

    //MARK: Properties
    @IBOutlet weak var thrValueLabel: UILabel!
    @IBOutlet weak var yawValueLabel: UILabel!
    @IBOutlet weak var pitchValueLabel: UILabel!
    @IBOutlet weak var rollValueLabel: UILabel!
    @IBOutlet weak var thrValue: UISlider!
    @IBOutlet weak var yawValue: UISlider!
    @IBOutlet weak var pitchValue: UISlider!
    @IBOutlet weak var rollValue: UISlider!
    @IBOutlet var addressValue: UITextField!

    let aux4Mode0Button = MyRadioButton(frame: CGRect(x: 20, y: 590, width: 60, height: 60))
    let aux4Mode1Button = MyRadioButton(frame: CGRect(x: 90, y: 590, width: 60, height: 60))
    let aux4Mode2Button = MyRadioButton(frame: CGRect(x: 160, y: 590, width: 60, height: 60))
    let aux4Mode3Button = MyRadioButton(frame: CGRect(x: 230, y: 590, width: 60, height: 60))
    let aux4Mode4Button = MyRadioButton(frame: CGRect(x: 300, y: 590, width: 60, height: 60))
    
    let aux4Mode0Label = UILabel(frame: CGRect(x: 30, y: 550, width: 60, height: 30))
    let aux4Mode1Label = UILabel(frame: CGRect(x: 100, y: 550, width: 60, height: 30))
    let aux4Mode2Label = UILabel(frame: CGRect(x: 170, y: 550, width: 60, height: 30))
    let aux4Mode3Label = UILabel(frame: CGRect(x: 240, y: 550, width: 60, height: 30))
    let aux4Mode4Label = UILabel(frame: CGRect(x: 320, y: 550, width: 60, height: 30))

    var inputStream: InputStream!
    var outputStream: OutputStream!
    //var host: CFString = "localhost" as CFString
    var host: CFString = "167.96.21.36" as CFString

    
    func initNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        //CFStreamCreatePairWithSocketToHost(nil, ("localhost" as! CFString), 80, &readStream, &writeStream)
        //inputStream = (readStream as! InputStream)
        //outputStream = (writeStream as! OutputStream)
        //var host: CFString = "localhost" as CFString
        //var host: CFString = "167.96.59.110" as CFString
        //var host: CFString = "169.254.222.91" as CFString
        var port: UInt32 = 8080
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        inputStream.open()
        outputStream.open()
    }

    func stream(_ theStream: Stream, handle streamEvent: Stream.Event) {
        print("stream event \(streamEvent)")
        switch streamEvent {
            case Stream.Event.openCompleted:
                print("Stream opened")
            case Stream.Event.hasBytesAvailable:
                if theStream == inputStream {
                    var buffer = [UInt8](repeating: 0, count: 1024)
                    var len: Int
                    while inputStream.hasBytesAvailable {
                        //len = inputStream.read(buffer, maxLength: MemoryLayout<buffer>.size)
                        len = inputStream.read(&buffer, maxLength: buffer.count)
                        if len > 0 {
                            //var output = String(bytes: buffer, length: len, encoding: String.Encoding.ascii)
                            var output = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.ascii.rawValue)
                            if nil != output {
                                print("server said: \(output)")
                                //self.messageReceived(output)
                            }
                        }
                    }
                }
            case Stream.Event.errorOccurred:
                print("Can not connect to the host!")
            case Stream.Event.endEncountered:
                theStream.close()
                theStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                //theStream = nil
            default:
                print("Unknown event")
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addressValue.delegate = self;
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))
        self.initNetworkCommunication()
        
        // Aux4
        aux4Mode0Label.text = "OFF"
        self.view.addSubview(aux4Mode0Label)
        aux4Mode1Label.text = "WP"
        self.view.addSubview(aux4Mode1Label)
        aux4Mode2Label.text = "RTH"
        self.view.addSubview(aux4Mode2Label)
        aux4Mode3Label.text = "HOLD"
        self.view.addSubview(aux4Mode3Label)
        aux4Mode4Label.text = "FN"
        self.view.addSubview(aux4Mode4Label)
        
        aux4Mode0Button.addTarget(self, action: #selector(manualAction0(sender:)), for: .touchUpInside)
        self.view.addSubview(aux4Mode0Button)
        aux4Mode1Button.addTarget(self, action: #selector(manualAction1(sender:)), for: .touchUpInside)
        self.view.addSubview(aux4Mode1Button)
        aux4Mode2Button.addTarget(self, action: #selector(manualAction2(sender:)), for: .touchUpInside)
        self.view.addSubview(aux4Mode2Button)
        aux4Mode3Button.addTarget(self, action: #selector(manualAction3(sender:)), for: .touchUpInside)
        self.view.addSubview(aux4Mode3Button)
        aux4Mode4Button.addTarget(self, action: #selector(manualAction4(sender:)), for: .touchUpInside)
        self.view.addSubview(aux4Mode4Button)
        aux4Mode0Button.isSelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissKeyboard(){
        addressValue.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.addressValue.resignFirstResponder()
        return true
    }

    //MARK: Actions
    
    @IBAction func connectHost(_ sender: UIButton) {
        print(addressValue.text)
        host = addressValue.text as! CFString
        print(host)
        self.initNetworkCommunication()
    }
    
    //MARK: Sliders
    @IBAction func thrSliderChange(_ sender: UISlider) {
        var sliderValue = Int(sender.value)
        thrValue.value = Float(sliderValue)
        thrValueLabel.text = "\(sliderValue)"
        
        var responseMSG = "thr:\(sliderValue) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
        
    }

    @IBAction func yawSlider(_ sender: UISlider) {
        var sliderValue = Double(Int(sender.value * 10.0)) / 10.0
        yawValue.value = Float(sliderValue)
        yawValueLabel.text = "\(sliderValue)"
        
        var responseMSG = "yaw:\(sliderValue) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    @IBAction func pitchSlider(_ sender: UISlider) {
        var sliderValue = Double(Int(sender.value * 10.0)) / 10.0
        pitchValue.value = Float(sliderValue)
        pitchValueLabel.text = "\(sliderValue)"
        
        var responseMSG = "pitch:\(sliderValue) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    @IBAction func rollSlider(_ sender: UISlider) {
        var sliderValue = Double(Int(sender.value * 10.0)) / 10.0
        rollValue.value = Float(sliderValue)
        rollValueLabel.text = "\(sliderValue)"
        
        var responseMSG = "roll:\(sliderValue) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }

    //MARK: Quick reset
    @IBAction func throttleMin(_ sender: UIButton) {
        thrValue.value = 1000
        thrValueLabel.text = "1000"
        
        var responseMSG = "thr:\(Int(thrValue.value)) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)

    }
    
    @IBAction func yawCenter(_ sender: UIButton) {
        yawValue.value = 0.0
        yawValueLabel.text = "0.0"
        
        var responseMSG = "yaw:\(yawValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    @IBAction func pitchCenter(_ sender: UIButton) {
        pitchValue.value = 0.0
        pitchValueLabel.text = "0.0"
        
        var responseMSG = "pitch:\(pitchValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    @IBAction func rollCenter(_ sender: UIButton) {
        rollValue.value = 0.0
        rollValueLabel.text = "0.0"
        
        var responseMSG = "roll:\(rollValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    //MARK: Inc and Dec
    @IBAction func thrInc(_ sender: UIButton) {
        thrValue.value = thrValue.value + 10
        thrValue.value = Float(Int(thrValue.value))
        thrValueLabel.text = "\(Int(thrValue.value))"
        
        var responseMSG = "thr:\(Int(thrValue.value)) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    @IBAction func thrDec(_ sender: UIButton) {
        thrValue.value = thrValue.value - 10
        thrValue.value = Float(Int(thrValue.value))
        thrValueLabel.text = "\(Int(thrValue.value))"
        
        var responseMSG = "thr:\(Int(thrValue.value)) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    @IBAction func yawInc(_ sender: UIButton) {
        yawValue.value = yawValue.value + 1.0
        yawValue.value = Float(Int(yawValue.value * 10.0)) / 10.0
        yawValueLabel.text = "\(yawValue.value)"
        
        var responseMSG = "yaw:\(yawValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    @IBAction func yawDec(_ sender: UIButton) {
        yawValue.value = yawValue.value - 1.0
        yawValue.value = Float(Int(yawValue.value * 10.0)) / 10.0
        yawValueLabel.text = "\(yawValue.value)"
        
        var responseMSG = "yaw:\(yawValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    @IBAction func pitchInc(_ sender: UIButton) {
        pitchValue.value = pitchValue.value + 1.0
        pitchValue.value = Float(Int(pitchValue.value * 10.0)) / 10.0
        pitchValueLabel.text = "\(pitchValue.value)"
        
        var responseMSG = "pitch:\(pitchValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    @IBAction func pitchDec(_ sender: UIButton) {
        pitchValue.value = pitchValue.value - 1.0
        pitchValue.value = Float(Int(pitchValue.value * 10.0)) / 10.0
        pitchValueLabel.text = "\(pitchValue.value)"
        
        var responseMSG = "pitch:\(pitchValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    @IBAction func rollInc(_ sender: UIButton) {
        rollValue.value = rollValue.value + 1.0
        rollValue.value = Float(Int(rollValue.value * 10.0)) / 10.0
        rollValueLabel.text = "\(rollValue.value)"
        
        var responseMSG = "roll:\(rollValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    @IBAction func rollDec(_ sender: UIButton) {
        rollValue.value = rollValue.value - 1.0
        rollValue.value = Float(Int(rollValue.value * 10.0)) / 10.0
        rollValueLabel.text = "\(rollValue.value)"
        
        var responseMSG = "roll:\(rollValue.value) "
        var dataMSG = [UInt8](responseMSG.utf8)
        outputStream.write(dataMSG, maxLength: dataMSG.count)
    }
    
    //MARK: Aux
    @IBAction func aux1S(_ sender: UISwitch) {
        if  sender.isOn {
            var responseMSG = "aux1:1 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
        else {
            var responseMSG = "aux1:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    
    @IBAction func aux2S(_ sender: UISwitch) {
        if  sender.isOn {
            var responseMSG = "aux2:1 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
        else {
            var responseMSG = "aux2:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    
    @IBAction func aux3S(_ sender: UISwitch) {
        if  sender.isOn {
            var responseMSG = "aux3:1 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
        else {
            var responseMSG = "aux3:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    @IBAction func aux4S(_ sender: UISwitch) {
        if  sender.isOn {
            var responseMSG = "aux4:1 "
            var dataMSG = [UInt8](responseMSG.utf8)
            
            //outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
        else {
            var responseMSG = "aux4:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            //outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    
    func manualAction0 (sender: MyRadioButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            aux4Mode1Button.isSelected = false
            aux4Mode2Button.isSelected = false
            aux4Mode3Button.isSelected = false
            aux4Mode4Button.isSelected = false
            var responseMSG = "aux4:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
        else {
            aux4Mode0Button.isSelected = true
        }
    }
    func manualAction1 (sender: MyRadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            aux4Mode0Button.isSelected = false
            aux4Mode2Button.isSelected = false
            aux4Mode3Button.isSelected = false
            aux4Mode4Button.isSelected = false
            var responseMSG = "aux4:1 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        } else{
            //label2.text = "Not Selected"
            aux4Mode0Button.isSelected = true
            var responseMSG = "aux4:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    func manualAction2 (sender: MyRadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            //label2.text = "Selected"
            aux4Mode0Button.isSelected = false
            aux4Mode1Button.isSelected = false
            aux4Mode3Button.isSelected = false
            aux4Mode4Button.isSelected = false
            var responseMSG = "aux4:2 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        } else{
            //label2.text = "Not Selected"
            aux4Mode0Button.isSelected = true
            var responseMSG = "aux4:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    func manualAction3 (sender: MyRadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            //label2.text = "Selected"
            aux4Mode0Button.isSelected = false
            aux4Mode1Button.isSelected = false
            aux4Mode2Button.isSelected = false
            aux4Mode4Button.isSelected = false
            var responseMSG = "aux4:3 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        } else{
            //label2.text = "Not Selected"
            aux4Mode0Button.isSelected = true
            var responseMSG = "aux4:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    func manualAction4 (sender: MyRadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            //label2.text = "Selected"
            aux4Mode0Button.isSelected = false
            aux4Mode1Button.isSelected = false
            aux4Mode2Button.isSelected = false
            aux4Mode3Button.isSelected = false
            var responseMSG = "aux4:4 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        } else{
            //label2.text = "Not Selected"
            aux4Mode0Button.isSelected = true
            var responseMSG = "aux4:0 "
            var dataMSG = [UInt8](responseMSG.utf8)
            outputStream.write(dataMSG, maxLength: dataMSG.count)
        }
    }
    
    @IBAction func didPressButton(_ sender: MyRadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            //label.text = "Selected"
        } else{
            //label.text = "Not Selected"
        }
    }
}

