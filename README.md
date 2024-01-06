# K-means visualization
A visualization of the k-means algorithm written in V.
This project has been written in a few hours in order to learn `gg`, the graphical library of V. It is inspired by a livestream of Tsoding where he did the same project in C, using `raylib`.

## How to run
Before you try running this program, make sure you have installed V, following the instructions from the [V documentation](https://github.com/vlang/v/blob/master/doc/docs.md#installing-v-from-source).
Then, after cloning this repo, run the following command:
```bash
v run .
```
This should start the visualization.

## How to use
Once the window is open:
- press `q` to close the window and quit the program.
- press `space` to perform a single iteration of the k-means algorithm (holding space works)

By default, the dataset consists of 500 points, split in 3 gaussians randomly placed and spread in the window, generated each time you start the program. You can change the number of clusters and the number of points by respectively setting `k` and `n` in the beginning of file [./src/main.v](./src/main.v).

## Useful links
Here are some links you might want to follow if you liked this repo:
- Tsoding stream that inspired this project: [Data mining in C](https://www.youtube.com/watch?v=kH-hqG34ylA)
- [K-means on Wikipedia](https://en.wikipedia.org/wiki/K-means_clustering)
- [V language](https://github.com/vlang/v)
