import argparse
import os
import itertools

import yaml

SPECS_DIR = 'specs'
SPECS_SEPARATOR = '\n'


def write_output(path, content):
    with open(path, 'w') as fp:
        fp.write(content)


def list_specs(dir):
    return sorted(
        f'{dir}/{fname}'
        for fname in os.listdir(dir)
        if os.path.isfile(os.path.join(dir, fname)))


def read_spec(path):
    with open(path, 'r') as fp:
        return list(yaml.safe_load_all(fp))


def render_specs(specs):
    kind = None
    for s in specs:
        if kind is None:
            kind = s['kind']
        if s['kind'] != kind:
            yield '\n---\n'
            kind = s['kind']
        yield s['spec']


def main(enable_hugo=False):
    specs = itertools.chain.from_iterable(
        read_spec(s) for s in list_specs(SPECS_DIR))
    return SPECS_SEPARATOR.join(render_specs(specs))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', type=str, required=True)
    args = parser.parse_args()

    output = main()
    write_output(args.output, output)
    print(f'Output: {args.output}')
