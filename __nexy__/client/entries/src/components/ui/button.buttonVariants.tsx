import { hydrateRoot } from 'react-dom/client'
import React from 'react'
import { buttonVariants as Component } from '../../../../../../src/components/ui/button'

const el = document.getElementById('button.buttonVariants-root')
if (el) hydrateRoot(el, React.createElement(Component))