import argparse
import os
import itertools

import yaml

SPECS_DIR = 'specs'
SPECS_SEPARATOR = '\n'


def write_output(fpath, content):
    with open(f'{fpath}', 'w') as fp:
        fp.write(content)


def get_specs(dir):
    return sorted(
        f'{dir}/{f}'
        for f in os.listdir(dir)
        if os.path.isfile(os.path.join(dir, f))
    )


def read_spec(path):
    basename = os.path.splitext(os.path.basename(path))[0]
    basename = basename.split('-')[0]
    basename = f'SPEC-{basename}'

    specs = []
    with open(path, 'r') as fp:
        documents = yaml.safe_load_all(fp)
        for i, doc in enumerate(documents):
            doc['name'] = f'{basename}-{i+1:03d}'
            specs.append(doc)

    return specs


def render_specs(specs):
    specs = list(specs)
    kind = specs[0]['kind']
    for s in specs:
        if s['kind'] != kind:
            yield '\n---\n'
            kind = s['kind']
        yield s['spec']


def main(enable_hugo=False):
    specs = itertools.chain.from_iterable(
        read_spec(s) for s in get_specs(SPECS_DIR))
    output = SPECS_SEPARATOR.join(render_specs(specs))
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', type=str, required=True)
    args = parser.parse_args()

    output = main()
    write_output(args.output, output)
    print(f'Output written to {args.output}')
