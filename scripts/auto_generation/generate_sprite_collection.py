"""
This file reads all filenames in the folder /assets/sprites, and constructs a struct in /src/rendering/sprite_collection.zig with fields equal to the filenames.
"""

import os
import jinja2

ROOT_FOLDER = "./../.."


RELATIVE_SPRITE_FOLDER = ROOT_FOLDER + "/assets/sprites"
SPRITE_FOLDER = os.path.curdir + "/assets/sprites"
SPRITE_COLLECTION_FILE = os.path.curdir + "/src/rendering/sprites.zig"

TEMPLATE_FOLDER = os.path.curdir + "/scripts/auto_generation/templates"
SPRITE_COLLECTION_TEMPLATE_FILE_NAME = "sprite_collection.jinja"


# This is where we declare what headers are expected in each sprite file.
# Headers contain information related to parsing the .sprite file.
# If a .sprite file does not contain these headers, then the game will crash on startup.
from typing import TypedDict


class FieldInfo(TypedDict):
    type: str
    coercion: str


sprite_headers: dict[str, FieldInfo] = {
    "rotation": FieldInfo(
        type="helpers.Direction",
        coercion="switch ({arg}[0]) "
        + "{{"
        + "'u' => helpers.Direction.Up, 'r' => helpers.Direction.Right, 'd' => helpers.Direction.Down, 'l' => helpers.Direction.Left, else => HeaderInitError.UnexpectedRotation, "
        + "}}",
    )
}


def main():
    environment = jinja2.Environment(loader=jinja2.FileSystemLoader(TEMPLATE_FOLDER))
    template = environment.get_template(SPRITE_COLLECTION_TEMPLATE_FILE_NAME)
    sprite_names = get_sprite_names()
    context = {
        "sprite_names": sprite_names,
        "sprite_folder": RELATIVE_SPRITE_FOLDER,
        "sprite_headers": sprite_headers,
    }

    rendered_file = template.render(context)

    with open(SPRITE_COLLECTION_FILE, "w") as f:
        print(f"Writing to file {SPRITE_COLLECTION_FILE}")
        f.write(rendered_file)
    print("Running zig fmt on generated file..")
    os.system("zig fmt src/rendering/sprites.zig")


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
