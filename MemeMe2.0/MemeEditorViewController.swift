//
//  MemeEditorViewController.swift
//  MemeMe2.0
//
//  Created by Shubham Jindal on 16/01/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //Setting the iboutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var countTopEdits = 0
    var countBottomEdits = 0
    var meme: MemeModel?
    
    //MARK: -Meme text attributes
    let memeTextAttributes:[String : Any] = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -6
    ]
    
    //MARK: -Function to set attributes of text fields
    func setTextField(_ textField: UITextField){
        //tag the textfields to distingush them
        
        topTextField.tag = 0
         bottomTextField.tag = 1
        
        //Setting the delegate
         textField.delegate = self
        
         //Setting the Attributes
        textField.backgroundColor = UIColor.clear
         textField.defaultTextAttributes = memeTextAttributes
         textField.textAlignment = .center
         switch textField.tag{
             case 0:
                 textField.text = "TOP"
             default:
                 textField.text = "BOTTOM"
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Setting the attributes for both the text fields
        setTextField(topTextField)
        setTextField(bottomTextField)
        
        //disable the share Button
        shareButton.isEnabled = false
        
        //disable cancel button
       // cancelButton.isEnabled = false
        
    }

    //MARK: -Method for sliding the view
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide() {
        view.frame.origin.y = 0
    }
    
    //Enabling camera button if camera is available
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
    }
    
    //Unsubscribing from notification
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: -Methods for subscribing and unsubscribing notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Processing of image
    func pickAnImageFromSource(_ source: UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        pickerController.sourceType = source
        
        present(pickerController, animated: true, completion: nil)
    }
    
    //Picking image from album
    @IBAction func pickAnImageFromAlbum(_ sender: AnyObject) {
        pickAnImageFromSource(UIImagePickerControllerSourceType.photoLibrary)
    }
    
    //Taking image from camera
    @IBAction func pickAnImageFromCamera (_ sender: AnyObject) {
        pickAnImageFromSource(UIImagePickerControllerSourceType.camera)
    }
    
    //Setting the image properties
    func imagePickerController(_ picker: UIImagePickerController,  didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageView.image = image
            shareButton.isEnabled = true}
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //clear the text of top and bottom when beging typing.
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        if topTextField.isFirstResponder && countTopEdits == 0{
            textField.text = ""
            countTopEdits += 1
        }
        
        if bottomTextField.isFirstResponder && countBottomEdits == 0{
            textField.text = ""
            countBottomEdits += 1
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: -Method for generating the meme
    func generateMemedImage() -> UIImage
    {
        //hiding the toolbar and navigation bar
        navBar.isHidden = true
        toolBar.isHidden = true
        
        //Combining the image and the text fields
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Enabling the toolbar and navigation bar again
        toolBar.isHidden = false
        navBar.isHidden = false
        return memedImage
    }
    
    //Saving the meme
    func save(){
        meme = MemeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        print("memed saved")
        
        //Add it to memes array on AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        if let meme = meme{
        appDelegate.memes.append(meme)
        }
        
    }
    
    //Hiding the status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }

    @IBAction func sendingThePicture(_ sender: AnyObject) {
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //Completion handeler
        controller.completionWithItemsHandler = {
            (_,completed: Bool,_,_)->Void
            in if completed{
                self.save()
               _ = self.navigationController?.popToRootViewController(animated: true)
            } else{ print("The image was not saved")}
        }
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    //Functioning of the cancel button
    @IBAction func cancelButton(_ sender: AnyObject) {
      _ =  navigationController?.popToRootViewController(animated: true)

    }
    
}




