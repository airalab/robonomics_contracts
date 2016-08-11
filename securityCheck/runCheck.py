#!/usr/bin/env python3
# -*- coding: utf8 -*-

import sys, os.path

class cached_property:
    """
    A property that is only computed once per instance and then replaces itself
    with an ordinary attribute. Deleting the attribute resets the property.
    Source: https://github.com/bottlepy/bottle/commit/fa7733e075da0d790d809aa3d2f53071897e6f76
    """  # noqa

    def __init__(self, func):
        self.__doc__ = getattr(func, '__doc__')
        self.func = func

    def __get__(self, obj, cls):
        if obj is None:
            return self
        value = obj.__dict__[self.func.__name__] = self.func(obj)
        return value

def cli_input(text, variants):
    while True:
        print('\n'+text)
        for v in variants:
            print('> [{0}]: {1}'.format(v.key, v))

        default = variants[0]
        answer = input('Select [{0}]: '.format(default.key))

        result = list(filter(lambda x: x.key == answer, variants)) 
        if len(result) > 0:
            return result[0]
        elif answer == '':
            return default
        else:
            print('`{0}` is not in variants [0..{1}]'.format(answer, len(variants)))

class Img:
    class Good:
        def __str__(self):
            return '![good](https://cdn.rawgit.com/primer/octicons/master/build/svg/check.svg)'
    
    class Warning:
        def __str__(self):
            return '![warning](https://cdn.rawgit.com/primer/octicons/master/build/svg/issue-opened.svg)' 

    class Danger:
        def __str__(self):
            return '![danger](https://cdn.rawgit.com/primer/octicons/master/build/svg/flame.svg)' 

class Opt:
    def __init__(self, key, img, txt):
        self.key = key
        self.img = img
        self.txt = txt

    def __str__(self):
        return self.txt

class Contract:
    def __init__(self, fname):
        pkgdir, self.name = os.path.split(fname)
        _, self.package = os.path.split(pkgdir) 
        self.name = self.name[:-4]

class Recomendations:
    @cached_property
    def external_calls(self):
        return cli_input('Внешние вызовы:', \
                        [ Opt('1', Img.Danger(),  'в большом количестве') \
                        , Opt('2', Img.Warning(), 'немного') \
                        , Opt('3', Img.Good(),    'отсутствуют') \
                        ])
 
    @cached_property
    def state_over_call(self):
        return cli_input('Состояние контракта:', \
                        [ Opt('1', Img.Danger(),  'не меняется, внешний вызов управляет логикой контракта') \
                        , Opt('2', Img.Warning(), 'меняется, логика зависит от внешних вызовов и состояния') \
                        , Opt('3', Img.Good(),    'логика работы зависит только от состояния') \
                        ])

    @cached_property
    def extcall_isolate(self):
        return cli_input('Внешние вызовы:', \
                        [ Opt('1', Img.Danger(),  'смешаны с логикой работы контракта') \
                        , Opt('2', Img.Warning(), 'вызываются в конце метода') \
                        , Opt('3', Img.Good(),    'вынесены в отдельные методы') \
                        ])

    @cached_property
    def integer_div(self):
        return cli_input('Целочисленное деление:', \
                        [ Opt('y', Img.Warning(), 'присутствует') \
                        , Opt('n', Img.Good(),    'отсутствует или используется множитель') \
                        ])

    @cached_property
    def zero_div(self):
        return cli_input('Проверка на ноль в качестве делителя:', \
                        [ Opt('n', Img.Danger(), 'отсутствует') \
                        , Opt('y', Img.Good(),   'присутствует')
                        ])

    @cached_property
    def var_overlflow(self):
        return cli_input('Проверка на переполнение переменных при арифметических операциях:', \
                        [ Opt('n', Img.Danger(), 'отсутствует') \
                        , Opt('y', Img.Warning(),'только при присваивании') \
                        , Opt('Y', Img.Good(),   'при любом использовании')
                        ])
    
    @cached_property
    def array_iteration(self):
        return cli_input('Перебор динамических массивов:', \
                        [ Opt('1', Img.Danger(),  'неконтролируемый перебор')
                        , Opt('2', Img.Warning(), 'присутсвует, расход газа контролируется') \
                        , Opt('3', Img.Good(),    'отсутствует либо число итераций постоянно') \
                        ])


    @cached_property
    def timestamp_logic(self):
        return cli_input('Логика работы контракта зависит от метки времени блока?', \
                        [ Opt('y', Img.Warning(), 'да') \
                        , Opt('n', Img.Good(),    'нет')
                        ])

    @cached_property
    def data_migration(self):
        return cli_input('Предусмотрен ли перенос данных контракта?', \
                        [ Opt('y', Img.Good(),    'да') \
                        , Opt('n', Img.Warning(), 'нет')
                        ])

    @cached_property
    def emergency_breaks(self):
        return cli_input('Присутствуют точки экстренного останова?', \
                        [ Opt('y', Img.Good(),    'да') \
                        , Opt('n', Img.Warning(), 'нет')
                        ])

    @cached_property
    def time_breaks(self):
        return cli_input('Критически важные действия принудительно разнесены во времени?', \
                        [ Opt('y', Img.Good(),    'да') \
                        , Opt('n', Img.Warning(), 'нет')
                        ])

    @cached_property
    def formal_verify(self):
        return cli_input('Проведена формальная верификация контракта?', \
                        [ Opt('y', Img.Good(),    'да') \
                        , Opt('n', Img.Warning(), 'нет')
                        ])

class Attacks:
    def __init__(self, recs):
        self.r = recs

    @property
    def depth_stack(self):
        result = 0
        result += int(self.r.external_calls.key)
        result += int(self.r.state_over_call.key)
        result += int(self.r.extcall_isolate.key)
        result /= 3.0
        if result < 2:
            return Img.Danger() 
        elif result < 3:
            return Img.Warning()
        else:
            return Img.Good()
    
    @property
    def race_condition(self):
        return self.r.extcall_isolate.img
    
    @property
    def dos_throw(self):
        return self.r.extcall_isolate.img
    
    @property
    def dos_gas_limit(self):
        result = 0
        result += int(self.r.array_iteration.key)
        result += int(self.r.extcall_isolate.key)
        result /= 2.0
        if result < 2:
            return Img.Danger()
        elif result < 3:
            return Img.Warning()
        else:
            return Img.Good()

def main():
    template = open('template.md', 'r').read()
    c = Contract(sys.argv[1])
    r = Recomendations()
    a = Attacks(r)
    md = template.format(contract=c, recs=r, att=a)
    open('{0}_{1}.md'.format(c.package, c.name), 'w').write(md)

if __name__ == '__main__':
    main()
