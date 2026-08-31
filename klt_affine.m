clear 
close all
%% scelta dei punti (Harris-Stephens)
np = 3; % cambiare questo valore per cambiare il numero dei punti da tracciare
I1 = imresize(im2double(rgb2gray(imread('img2/1.jpg'))), .1);

fig_top = figure(Name='Prima immagine');

imshow(I1); hold on

S = fspecial('sobel');
Iu = filter2(S', I1);
Iv = filter2(S, I1);

sigma = 4;
G = fspecial('gaussian', ceil(sigma*6+1), sigma);
Iuu = filter2(G, Iu.*Iu, 'same');
Ivv = filter2(G, Iv.*Iv, 'same');
Iuv = filter2(G, Iu.*Iv, 'same');

tr = Iuu + Ivv;
det = Iuu.*Ivv - Iuv.*Iuv;
C = det - 0.04*(tr.*tr);

% togli la scacchiera
mask = false(size(C));
mask(70:200, 180:260) = true;
C(~mask) = -Inf;

[val, idx] = extrema2(C);
idx = idx(1:np);
[j, i] = ind2sub(size(C), idx);


points = [i j];
figure(fig_top);
plot (points(:,1), points(:,2), 'og');

%% finestra nxn attorno a mi
width = 10; % pixel in ogni direzione attorno a m
fig_track = figure(Visible="off");
for ptIdx = 1:np
    I1 = imresize(im2double(rgb2gray(imread('img2/1.jpg'))), .1);
    m = points(ptIdx, :)';
    tracked = m;
    p = [0 0 0 0 0 0]';
    for n = 2:1:88
    % for n = 133:187
        wx = m(1)-width : m(1)+width;
        wy = m(2)-width : m(2)+width;
        
        Wx = repmat(wx, 2*width+1, 1);
        Wy = repmat(wy', 1, 2*width+1);
        
        W1 = interp2(I1, Wx, Wy);
        
        %% calcolo spostamento, ciclo:
        % calcolo r = I2(wi+x)-I1(wi)
        % calcolo jacobiano J = gradiente(I2(wi+x))
        % calcolo dx = -(J'*J)\(J'*r)
        % aggiornamento x = x + dx
        maxIter = 20; tol = 1e-4;
    
        I2 = imresize(im2double(rgb2gray(imread(['img2/' num2str(n) '.jpg']))), .1);
        [DX, DY] = gradient(I2);

        [Wx, Wy] = meshgrid(-10:10, -10:10);
        p = [0 0 0 0 p(5) p(6)]';
        for iter = 1:maxIter
            Wtx = m(1)+Wx*(1+p(1)) + Wy*p(3) + p(5);
            Wty = m(2)+Wx*p(2) + Wy*(1+p(4)) + p(6);
            W2 = interp2(I2, Wtx, Wty);
            r = W2 - W1;
            r = r(:);
            
            Jx = interp2(DX, Wtx, Wty);
            Jy = interp2(DY, Wtx, Wty);
            J = [Wx(:).*Jx(:) Wx(:).*Jy(:) Wy(:).*Jx(:) Wy(:).*Jy(:) Jx(:) Jy(:)];
        
            H = J'*J + 0.1*eye(6);
            b = J'*r;
            dp = -H\b;
            p = p + dp;
            if (norm(dp) < tol)
                break;
            end
        end
        I1 = I2;
        m(1) = m(1) + p(5);
        m(2) = m(2) + p(6);
        figure(fig_track);
        imshow(I2);
        hold on;
        plot(m(1), m(2), 'ro');
        hold off;
        saveas(fig_track, ['result/tracked_' num2str(ptIdx) '_' num2str(n) '.jpg']);
        tracked = [tracked m];
    end
    figure(fig_top);
    plot(tracked(1,:), tracked(2,:), 'x-');
    legend show;
end