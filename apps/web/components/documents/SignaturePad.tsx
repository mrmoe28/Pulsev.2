'use client';

import { useState, useRef, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Pen, 
  Type, 
  Upload, 
  Download, 
  Check, 
  X, 
  FileText,
  Trash2
} from 'lucide-react';

interface SignaturePadProps {
  onSignatureComplete: (signatureData: string) => void;
  onCancel: () => void;
}

export function SignaturePad({ onSignatureComplete, onCancel }: SignaturePadProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [hasSignature, setHasSignature] = useState(false);
  const [signatureType, setSignatureType] = useState<'draw' | 'type' | 'upload'>('draw');
  const [typedSignature, setTypedSignature] = useState('');

  const startDrawing = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.beginPath();
    ctx.moveTo(x, y);
    setIsDrawing(true);
  };

  const draw = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!isDrawing) return;

    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#000000';
    ctx.lineTo(x, y);
    ctx.stroke();
    
    setHasSignature(true);
  };

  const stopDrawing = () => {
    setIsDrawing(false);
  };

  const clearSignature = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    setHasSignature(false);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const img = new Image();
      img.onload = () => {
        const canvas = canvasRef.current;
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        if (!ctx) return;

        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        setHasSignature(true);
      };
      img.src = event.target?.result as string;
    };
    reader.readAsDataURL(file);
  };

  const handleSignatureSubmit = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    if (signatureType === 'type' && typedSignature.trim()) {
      // For typed signature, draw it on canvas first
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.font = '32px cursive';
        ctx.fillStyle = '#000000';
        ctx.textAlign = 'center';
        ctx.fillText(typedSignature, canvas.width / 2, canvas.height / 2);
      }
    }

    const signatureData = canvas.toDataURL();
    onSignatureComplete(signatureData);
  };

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // Set canvas size
    canvas.width = 400;
    canvas.height = 200;

    // Set canvas background to white
    const ctx = canvas.getContext('2d');
    if (ctx) {
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
    }
  }, []);

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>Electronic Signature</CardTitle>
        <CardDescription>
          Sign this document using one of the methods below
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Signature Type Selection */}
        <div className="flex gap-2">
          <Button
            variant={signatureType === 'draw' ? 'default' : 'outline'}
            onClick={() => setSignatureType('draw')}
            size="sm"
          >
            <Pen className="h-4 w-4 mr-2" />
            Draw
          </Button>
          <Button
            variant={signatureType === 'type' ? 'default' : 'outline'}
            onClick={() => setSignatureType('type')}
            size="sm"
          >
            <Type className="h-4 w-4 mr-2" />
            Type
          </Button>
          <Button
            variant={signatureType === 'upload' ? 'default' : 'outline'}
            onClick={() => setSignatureType('upload')}
            size="sm"
          >
            <Upload className="h-4 w-4 mr-2" />
            Upload
          </Button>
        </div>

        {/* Signature Input Area */}
        <div className="space-y-4">
          {signatureType === 'draw' && (
            <div className="space-y-2">
              <div className="border-2 border-gray-300 rounded-lg p-4 bg-white">
                <canvas
                  ref={canvasRef}
                  onMouseDown={startDrawing}
                  onMouseMove={draw}
                  onMouseUp={stopDrawing}
                  onMouseLeave={stopDrawing}
                  className="border border-gray-200 rounded cursor-crosshair w-full"
                  style={{ maxWidth: '100%', height: 'auto' }}
                />
              </div>
              <div className="flex justify-between items-center">
                <p className="text-sm text-gray-500">Draw your signature above</p>
                <Button variant="outline" size="sm" onClick={clearSignature}>
                  <Trash2 className="h-4 w-4 mr-2" />
                  Clear
                </Button>
              </div>
            </div>
          )}

          {signatureType === 'type' && (
            <div className="space-y-2">
              <input
                type="text"
                value={typedSignature}
                onChange={(e) => setTypedSignature(e.target.value)}
                placeholder="Type your full name here"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 font-cursive text-2xl text-center"
                style={{ fontFamily: 'cursive' }}
              />
              <p className="text-sm text-gray-500 text-center">
                Your typed name will be converted to a signature style
              </p>
            </div>
          )}

          {signatureType === 'upload' && (
            <div className="space-y-2">
              <p className="text-sm text-gray-500 text-center">
                Upload an image of your signature (PNG, JPG, or GIF)
              </p>
              <div className="max-w-md mx-auto">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileUpload}
                  className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                />
              </div>
            </div>
          )}
        </div>

        {/* Legal Agreement */}
        <div className="bg-blue-50 p-4 rounded-lg">
          <h4 className="font-medium text-blue-900 mb-2">Electronic Signature Agreement</h4>
          <p className="text-sm text-blue-800">
            By signing this document electronically, you agree that your electronic signature 
            is the legal equivalent of your manual signature on this document. You also agree 
            that no certification authority or other third party verification is necessary to 
            validate your electronic signature.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row gap-3 justify-end">
          <Button
            variant="outline"
            onClick={onCancel}
            className="flex items-center"
          >
            <X className="h-4 w-4 mr-2" />
            Cancel
          </Button>
          <Button
            onClick={handleSignatureSubmit}
            disabled={!hasSignature && !typedSignature.trim()}
            className="flex items-center"
          >
            <Check className="h-4 w-4 mr-2" />
            Sign Document
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

interface DocumentViewerProps {
  documentId: string;
  documentTitle: string;
  onSignatureRequest: () => void;
  signatures?: Array<{
    id: string;
    signerName: string;
    signerEmail: string;
    status: 'pending' | 'signed' | 'declined';
    signedAt?: string;
  }>;
}

export function DocumentViewer({ documentId, documentTitle, onSignatureRequest, signatures = [] }: DocumentViewerProps) {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate loading document
    setTimeout(() => setIsLoading(false), 1500);
  }, []);

  return (
    <div className="space-y-6">
      {/* Document Header */}
      <Card>
        <CardHeader>
          <div className="flex justify-between items-start">
            <div>
              <CardTitle>{documentTitle}</CardTitle>
              <CardDescription>
                Document ID: {documentId}
              </CardDescription>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" size="sm">
                <Download className="h-4 w-4 mr-2" />
                Download
              </Button>
              <Button onClick={onSignatureRequest} size="sm">
                <Pen className="h-4 w-4 mr-2" />
                Request Signature
              </Button>
            </div>
          </div>
        </CardHeader>
      </Card>

      {/* Document Preview */}
      <Card>
        <CardContent className="p-6">
          {isLoading ? (
            <div className="flex items-center justify-center h-96">
              <div className="text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
                <p className="text-gray-500">Loading document...</p>
              </div>
            </div>
          ) : (
            <div className="bg-gray-100 border-2 border-dashed border-gray-300 rounded-lg h-96 flex items-center justify-center">
              <div className="text-center">
                <FileText className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500 mb-2">PDF Document Preview</p>
                <p className="text-sm text-gray-400">
                  In production, this would show the actual PDF document
                </p>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Signature Status */}
      {signatures.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Signature Status</CardTitle>
            <CardDescription>
              Track the signing progress of this document
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {signatures.map((signature) => (
                <div key={signature.id} className="flex items-center justify-between p-3 border rounded-lg">
                  <div>
                    <p className="font-medium">{signature.signerName}</p>
                    <p className="text-sm text-gray-500">{signature.signerEmail}</p>
                  </div>
                  <div className="text-right">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      signature.status === 'signed' 
                        ? 'bg-green-100 text-green-800'
                        : signature.status === 'declined'
                        ? 'bg-red-100 text-red-800'
                        : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {signature.status === 'signed' && <Check className="h-3 w-3 mr-1" />}
                      {signature.status === 'declined' && <X className="h-3 w-3 mr-1" />}
                      {signature.status.charAt(0).toUpperCase() + signature.status.slice(1)}
                    </span>
                    {signature.signedAt && (
                      <p className="text-xs text-gray-400 mt-1">
                        {new Date(signature.signedAt).toLocaleDateString()}
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

export default SignaturePad;
