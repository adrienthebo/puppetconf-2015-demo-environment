# -*- mode: ruby -*-
# vi: set ft=ruby :

paths = [File.expand_path('config', File.dirname(__FILE__))]

Vagrant.configure('2', &ConfigBuilder.load(:yaml, :yamldir, paths))
