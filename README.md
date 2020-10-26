# Flight Configure

Application configuration tool

## Overview

A tool for configuring applications within the flight ecosystem.

Each application plugins in its configuration definition and post configure
script. Then `flight configure` does the rest!

## Installation

With a suitable version of ruby:

```
$ bundle install
```

## Configuration

[See configuration document](etc/00-defaults.conf)

## Operation

To list available applications

```
bin/configure avail
```

To configure an application

```
bin/configure run <app-name>

# Or

bin/configure <app-name>
```

To get a single configuration value

```
bin/configure get <app-name> <key>
```

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Copyright and License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2020-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Flight Configure is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the [Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.
