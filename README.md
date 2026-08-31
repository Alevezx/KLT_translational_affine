Implementazione dell'algoritmo di Kanada-Lucas-Tomasi (KLT) per il tracciamento di punti salienti in MATLAB, con un modello traslazionale (klt_trasl.m) e un modello affine (klt_affine.m) con ottimizzazione di Levenberg-Marquardt.

Per la scelta dei punti viene usato Harris-Stephens all'interno dell'oggetto centrale.

- il punto 1 viene tracciato correttamente sia con il modello traslazionale, sia con quello affine;
- il punto 2 ha buoni autovalori, ma viene perso a causa di forti occlusioni,
- il punto 3 ha autovalori sufficientemente buoni da essere tracciato correttamente dal modello traslazionale, ma si nota una lieve deriva (~5 pixel) col modello affine.

Nota: il modello affine implementa un fattore di damping fisso (lambda = 0.1) per assicurare la stabilità numerica e prevenire matrici singolari nel ciclo di Gauss-Newton.