
import SwiftUI
import AVFoundation
import Vision
import Combine

struct FaceVerificationView: View {
    @StateObject private var cameraModel = FaceVerificationViewModel()
    @Environment(\.dismiss) var dismiss
    
    var onSuccess: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let session = cameraModel.session {
                CameraPreview(session: session)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Overlay
            VStack {
                Text("Vérification Faciale")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .shadow(radius: 4)
                
                Text(cameraModel.statusMessage)
                    .font(.headline)
                    .foregroundColor(cameraModel.isVerified ? .green : .white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.top, 10)
                
                Spacer()
                
                if cameraModel.isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .padding(.bottom, 50)
                        .transition(.scale)
                } else {
                    // Face frame guide
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 350)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 4, dash: [10]))
                        )
                        .padding(.bottom, 50)
                }
                
                Button("Annuler") {
                    cameraModel.stopSession()
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            cameraModel.checkPermissions()
        }
        .onDisappear {
            cameraModel.stopSession()
        }
        .onChange(of: cameraModel.isVerified) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onSuccess()
                    dismiss() // Dismiss verification view to show CreateOffer (handled by parent usually, but good to close this)
                    // Actually, the parent should likely handle the switch, so dismissing might be right or wrong depending on implementation.
                    // If Dashboard presents this as a sheet, dismissing it and THEN presenting CreateOffer might be tricky if not coordinated.
                    // For now, let's assume onSuccess triggers state change in parent.
                }
            }
        }
    }
}

class FaceVerificationViewModel: NSObject, ObservableObject {
    @Published var session: AVCaptureSession?
    @Published var isVerified = false 
    @Published var statusMessage = "Placez votre visage dans le cadre"
    
    private var videoOutput = AVCaptureVideoDataOutput()
    private var faceDetectionRequest: VNDetectFaceRectanglesRequest?
    
    override init() {
        super.init()
        setupVision()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { self?.setupCamera() }
                }
            }
        default:
            statusMessage = "Accès caméra refusé"
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            statusMessage = "Caméra introuvable"
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(videoOutput)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.startRunning()
            DispatchQueue.main.async {
                self?.session = session
            }
        }
    }
    
    func stopSession() {
        session?.stopRunning()
    }
    
    private func setupVision() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
                DispatchQueue.main.async {
                    if !self.isVerified {
                        self.statusMessage = "Aucun visage détecté"
                    }
                }
                return
            }
            
            // Simple check: is there at least one face?
            // In a real verification app, you'd match this against a stored face.
            // Here we just checking "is person".
            
            DispatchQueue.main.async {
                if !self.isVerified {
                    self.isVerified = true
                    self.statusMessage = "Visage détecté !"
                    // Stop checking to save resources? Or keep running until dismissal?
                    // Let's keep one generic check.
                }
            }
        }
    }
}

extension FaceVerificationViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), !isVerified else { return }
        
        // Ensure request exists
        guard let request = faceDetectionRequest else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        try? handler.perform([request])
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
