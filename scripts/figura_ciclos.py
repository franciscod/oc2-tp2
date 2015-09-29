import matplotlib.pyplot as plt
import sys

from contextlib import contextmanager

ROOT_IMG = 'informe/img/gen/'


def main():

    pngname = sys.argv[1]
    title = sys.argv[2]
    keys = sys.argv[3:]
    vals = []

    for n in keys:
        vals.append(float(open('data/' + n + '.txt').read()))

    plot_ciclos(title, keys, vals, pngname)


@contextmanager
def null():
    yield


def plot_ciclos(
        titulo,
        keys,
        vals,
        png_name,
        log=False,
        ):

    k = len(keys)
    width = 0.5/k

    lefts = [x/k for x in range(k)]
    lefts_c = [l + width/2 for l in lefts]

    rightmost = (lefts[-1] + width)

    heights = vals

    # with plt.xkcd():
    with null():
        fig = plt.figure()
        ax = fig.add_axes((0.1, 0.1, 0.8, 0.8))
        ax.bar(lefts, heights, width, color=['r', 'g', 'b'], log=log)

        ax.spines['right'].set_color('none')
        ax.spines['top'].set_color('none')

        ax.set_xticks(lefts_c)
        ax.set_xticklabels(keys)
        # ax.set_yticks([])
        ax.xaxis.set_ticks_position('bottom')
        # ax.yaxis.set_ticks_position('left')

        ax.set_xlim([-rightmost*.1, rightmost*1.1])
        ax.set_ylim([0, max(heights)*1.1])

        rects = ax.patches
        labels = [vals[i] for i in range(len(rects))]

        for rect, label in zip(rects, labels):
            height = rect.get_height()
            ax.text(rect.get_x() + rect.get_width()/2, height + 5,
                    label, ha='center', va='bottom')

        plt.xlabel('implementacion')
        plt.ylabel('# ciclos insumidos por llamada')

        plt.title(titulo + (" (log)" if log else ""))

    plt.savefig(ROOT_IMG + png_name)


# d = {'asd' : 40, 'qwe': 565, 'iop': 200, 'lel': 80}
# plot_ciclos( "Titulito",
#         ('asd', 'qwe', 'iop', 'lel', 'e', 'wach'),
#         (40, 565, 200, 80, 300, 400),
#         'diff.png')
# exit()
if __name__ == '__main__':
    main()
