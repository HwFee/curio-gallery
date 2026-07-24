import { createContext, lazy, Suspense, useCallback, useContext, useState, type ReactNode } from 'react'
import type { ViewerState } from '@/components/gallery/Viewer'
import type { Work } from '@/types/work'

const Viewer = lazy(() => import('@/components/gallery/Viewer'))

interface ViewerApi {
  openViewer: (list: Work[], index: number, el?: HTMLElement | null) => void
}

const Ctx = createContext<ViewerApi>({ openViewer: () => {} })

export const useViewer = () => useContext(Ctx)

export function ViewerProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<ViewerState | null>(null)

  const openViewer = useCallback((list: Work[], index: number, el?: HTMLElement | null) => {
    setState({ list, index, originRect: el ? el.getBoundingClientRect() : null })
  }, [])

  return (
    <Ctx.Provider value={{ openViewer }}>
      {children}
      {state && (
        <Suspense fallback={null}>
          <Viewer state={state} onClose={() => setState(null)} />
        </Suspense>
      )}
    </Ctx.Provider>
  )
}
