"""
This file reads all filenames in the folder /assets/sprites, and constructs a struct in /src/rendering/sprite_collection.zig with fields equal to the filenames.
"""

import os
import jinja2

ROOT_FOLDER = "./../.."


RELATIVE_SPRITE_FOLDER = ROOT_FOLDER + "/assets/sprites"
SPRITE_FOLDER = os.path.curdir + "/assets/sprites"
SPRITE_COLLECTION_FILE = os.path.curdir + "/src/rendering/sprite_collection.zig"

TEMPLATE_FOLDER = os.path.curdir + "/scripts/auto_generation/templates"
SPRITE_COLLECTION_TEMPLATE_FILE_NAME = "sprite_collection.jinja"


def main():
    environment = jinja2.Environment(loader=jinja2.FileSystemLoader(TEMPLATE_FOLDER))
    template = environment.get_template(SPRITE_COLLECTION_TEMPLATE_FILE_NAME)
    sprite_names = get_sprite_names()
    context = {
        "sprite_names": sprite_names,
        "sprite_folder": RELATIVE_SPRITE_FOLDER,
    }

    rendered_file = template.render(context)

    with open(SPRITE_COLLECTION_FILE, "w") as f:
        f.write(rendered_file)


def get_sprite_names() -> list[str]:
    files = [
        f
        for f in os.listdir(SPRITE_FOLDER)
        if os.path.isfile(os.path.join(SPRITE_FOLDER, f))
    ]
    sprite_names = [f.split(".")[0] for f in files if f.endswith(".sprite")]
    return sprite_names


if __name__ == "__main__":
    main()
