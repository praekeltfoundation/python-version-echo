from apistar import Route
from apistar import environment, typesystem
from apistar.frameworks.wsgi import WSGIApp as App


__version__ = '0.0.10'
VERSION = __version__


class Env(environment.Environment):
    properties = {
        'DEBUG': typesystem.boolean(default=False),
        'ECHO': typesystem.string(default=''),
    }


env = Env()

settings = {
    'DEBUG': env['DEBUG'],
    'ECHO': env['ECHO'],
}


def echo():
    return {'version': __version__, 'echo': settings['ECHO']}


routes = [
    Route('/', 'GET', echo),
]

app = App(
    routes=routes,
    settings=settings,
)

if __name__ == '__main__':
    app.main()
