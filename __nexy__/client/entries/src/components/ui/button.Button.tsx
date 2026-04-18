import { hydrateRoot } from 'react-dom/client'
import React from 'react'
import { Button as Component } from '../../../../../../src/components/ui/button'

const el = document.getElementById('button.Button-root')
if (el) hydrateRoot(el, React.createElement(Component))