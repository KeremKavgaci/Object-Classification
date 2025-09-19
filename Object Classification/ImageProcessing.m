% Görüntüyü yükle
image = imread('uçak - helikopter.png');

% Görseli göster
idisp(image)

% Görüntüyü gri tonlamalıya çevir
grayImage = rgb2gray(image);

% irank fonksiyonnu çalışmadığı için medyan filtresi farklı şekilde
% oluşturarak tuz ve karabiber gürültüsünü giderme işlemi yapıldı

% Filtrelenmiş görüntü için bir matris oluştur
[m, n] = size(grayImage);
filteredImage = zeros(m, n);

% Filtre penceresi boyutu (3x3)
windowSize = 3;
halfWindow = floor(windowSize / 2);

% Medyan filtresini uygulama
for i = 1 + halfWindow : m - halfWindow
    for j = 1 + halfWindow : n - halfWindow
        % 3x3 komşuluk penceresini al
        neighborhood = grayImage(i - halfWindow:i + halfWindow, j - halfWindow:j + halfWindow);
        
        % Pencere içindeki piksellerin medyanını hesapla
        filteredImage(i, j) = median(neighborhood(:));
    end
end

% Filtrelenmiş görüntüyü uint8 türüne dönüştür
filteredImage = uint8(filteredImage);

% filtrelenmiş görüntüyü göster
idisp(filteredImage)

% filtrelenmiş görüntüyü bir eşik değeri belirleyerek 
% ikili hale çevirme işlemi
% Normalde eşik değer olarak 50 seçilmişti ancak nesne tanıma aşamasında
% iblob fonksiyonu çok fazla nesne bulduğu için RAM yetersiz kalıyordu
% bu nedenle daha az nesne belirgin olacak şekilde 
% 30 eşik değeri seçilmiştir
x = filteredImage >= 30

% İkili hale gelen siyah beyaz görseli göster
idisp(x)

% Görselin sınırlarını bulma işlemi
S = kcircle(3)
closed = iclose(x, S)
clean = iopen(closed, S)
opened = iopen(x, S)
closed = iclose(opened, S)


eroded = imorph(x, kcircle(3), 'min');

% Sınırları bulunmuş görseli göster
idisp(clean - eroded)

boundry = clean - eroded

% Görseldeki nesneleri tanımak için ilabel fonksiyonu kullanıldı

[label, m] = ilabel(boundry)

% Görselde objelerin renklendirilmiş ve arka plandan ayırılmış hali
idisp(label, 'colormap', jet, 'bar')

% Nesne tanıma aşaması
fv = iblobs(boundry, 'boundary', 'class', 1)

% Çıkarımlarda bulunmak için bazı parametrelerin histogram grafiği
% oluşturuldu
histogram(fv.area, 100)
title("area")
histogram(fv.aspect, 100)
title("aspect")
histogram(fv.circularity, 100)
title("circularity")
histogram(fv.perimeter, 100)
title("perimeter")
histogram(fv.theta, 100)
title("theta")
histogram(fv.bboxarea, 100)
title("bboxarea")

% Sınıflandırma için boş diziler oluştur
helicopters = [];
airplanes = [];

% aspect özelliğine göre nesnelerin sınıflarndırılmasına karar verildi.
% 0.83 katsayısı tekrar tekrar denenerek bulundu.
for k = 1:length(fv)
if fv(k).aspect > 0.83  
        airplanes = [airplanes; fv(k)];
    else  
        helicopters = [helicopters; fv(k)];
    end
end

% Görseli göster ve sınıflandırmayı çizdir
idisp(image);
hold on;

% Helikopterleri yeşil çerçeve ile çiz
for k = 1:length(helicopters)
    helicopters(k).plot_boundary('g', 'LineWidth', 2);
    helicopters(k).plot_box('g');
end

% Uçakları kırmızı çerçeve ile çiz
for k = 1:length(airplanes)
    airplanes(k).plot_boundary('r', 'LineWidth', 2);
    airplanes(k).plot_box('r');
end

hold off;

% Sınıflandırılmış nesne sayılarını yazdır
fprintf('Toplam Helikopter Sayısı: %d\n', length(helicopters));
fprintf('Toplam Uçak Sayısı: %d\n', length(airplanes));