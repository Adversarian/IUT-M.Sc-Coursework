from glob import glob
import numpy as np
from PIL import Image


def prep_ds(parent_dir, split=0.1):
    img_paths = glob(parent_dir + '/*')
    x = []
    y = []
    for img_path in img_paths:
        gray_img = Image.open(img_path).convert('L')
        gray_img = np.asarray(gray_img)
        im_width, im_height = gray_img.shape
        # Pad with 0 to use with GAP
        padded_gray = np.full((im_width + 3, im_height + 2), 0)
        padded_gray[2:-1, 2:] = gray_img
        x_temp = []
        y_temp = []
        for i in range(2, im_width + 2):
            for j in range(2, im_height + 2):
                # W, N, NW, NE, WW, NN, NNE
                x_temp.append([
                    padded_gray[i - 1, j],
                    padded_gray[i, j - 1],
                    padded_gray[i - 1, j - 1],
                    padded_gray[i + 1, j - 1],
                    padded_gray[i - 2, j],
                    padded_gray[i, j - 2],
                    padded_gray[i + 1, j - 2]
                ])
                y_temp.append(padded_gray[i, j])
        x_temp = np.asarray(x_temp, dtype=np.uint8)
        y_temp = np.asarray(y_temp, dtype=np.uint8)
        indices = np.arange(x_temp.shape[0])
        np.random.shuffle(indices)
        x.extend(x_temp[:int(x_temp.shape[0]*split)])
        y.extend(y_temp[:int(y_temp.shape[0]*split)])
    x = np.asarray(x, dtype=np.uint8)
    y = np.asarray(y, dtype=np.uint8)
    indices = np.arange(x.shape[0])
    np.random.shuffle(indices)
    np.save(parent_dir + '/X', x[indices])
    np.save(parent_dir + '/Y', y[indices])


# if __name__ == '__main__':
prep_ds(r'Dataset')
